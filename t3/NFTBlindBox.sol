// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 导入依赖库：标准NFT、权限控制、防重入、Chainlink VRF随机数
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title NFT盲盒合约
 * @dev 功能：白名单预售 + 公售 + VRF真随机开盒 + 稀有度自动分配


https://violet-immediate-cicada-846.mypinata.cloud/ipfs/bafybeidvgbvyfden5jxej3svqt2z2frtqaisaez4myhb2bd4zh55zuoqju/common/3.json
思路
1，在创建合约之前  需要先把图片和matedata.json准备好，并上传到ips中，为了能够完整的拼出url地址，
需要先创建一个外层文件夹里面创建4个文件夹分别是common,rare,epic,legendary，然后再这个4个文件夹中分别创建按1.json  2.json 3.json
按照这个规则
 return string(abi.encodePacked(  _baseTokenURI, "/", _rarityToString(rarity), "/", _toString(tokenId),".json"));
其中_baseTokenURI = ipfs://bafybeidvgbvyfden5jxej3svqt2z2frtqaisaez4myhb2bd4zh55zuoqju
    _rarityToString(rarity)=common
    _toString(tokenId),".json"=3.json

2，

框架思路 写出一个通过随机数获取盲盒开盒后的稀有度
需要界定什么时候开卖



 */
contract NFTBlindBox is ERC721, Ownable, ReentrancyGuard, VRFConsumerBaseV2 {

    // ========================= 事件定义 =========================
    // 用户购买盲盒事件
    event BoxPurchased(address indexed buyer, uint256 indexed tokenId);
    // 盲盒开盒事件
    event BoxRevealed(uint256 indexed tokenId, Rarity rarity);
    // 稀有度分配事件
    event RarityAssigned(uint256 indexed tokenId, Rarity rarity);
    // 销售阶段切换事件
    event SalePhaseChanged(SalePhase newPhase);

    // ========================= 枚举定义 =========================
    /**
     * @dev NFT稀有度等级（概率按万分之计算）
     */
    enum Rarity {
        Common,      // 普通   60%
        Rare,        // 稀有   25%
        Epic,        // 史诗   12%
        Legendary    // 传说    3%
    }

    /**
     * @dev 销售阶段
     */
    enum SalePhase {
        NotStarted,  // 未开始
        Whitelist,   // 白名单预售
        Public       // 公售
    }

    /**
     * @dev 盲盒数据结构
     */
    struct BlindBox {
        bool purchased;     // 是否已购买
        bool revealed;      // 是否已开盒
        uint256 purchaseTime;// 购买时间
        uint256 revealTime;  // 开盒时间
    }

    // ========================= 全局状态变量 =========================
    uint256 public totalSupply;     // 当前已铸造数量
    uint256 public maxSupply;       // 最大发行总量
    uint256 public price;           // 单个盲盒价格
    bool public saleActive;         // 销售是否开启
    SalePhase public currentPhase;  // 当前销售阶段
    uint256 public maxPerWallet;    // 每个钱包最大购买数量

    // ========================= VRF 随机数配置 =========================
    VRFCoordinatorV2Interface private vrfCoordinator;  // VRF协调器合约
    bytes32 private keyHash;                          // VRF密钥哈希
    uint64 private subscriptionId;                    // VRF订阅ID
    uint32 private callbackGasLimit = 100000;         // 回调函数Gas限制
    uint16 private requestConfirmations = 3;          // 区块确认数
    uint32 private numWords = 1;                      // 每次请求1个随机数

    // ========================= 映射存储 =========================
    mapping(uint256 => Rarity) public tokenRarity;        // tokenID => 稀有度
    mapping(uint256 => BlindBox) public blindBoxes;       // tokenID => 盲盒信息
    mapping(uint256 => uint256) public requestIdToTokenId;// VRF请求ID => tokenID
    mapping(uint256 => string) private _tokenURIs;       // tokenID => 元数据链接
    mapping(address => bool) public whitelist;           // 地址 => 是否白名单
    mapping(address => uint256) public whitelistMinted;  // 白名单地址已 mint 数量

    // ========================= 概率常量（万分之） =========================
    uint256 private constant COMMON_PROBABILITY = 6000;    // 普通 60%
    uint256 private constant RARE_PROBABILITY = 2500;     // 稀有 25%
    uint256 private constant EPIC_PROBABILITY = 1200;      // 史诗 12%
    uint256 private constant LEGENDARY_PROBABILITY = 300; // 传说 3%

    uint256 public constant whitelistMaxMint = 3;         // 白名单每人最多买3个

    string private _baseTokenURI;  // 元数据基础路径

    // ========================= 构造函数：部署时初始化 =========================
    constructor(
        string memory name,          // NFT名称
        string memory symbol,        // NFT符号
        uint256 _maxSupply,          // 最大发行量
        uint256 _price,              // 单价
        address _vrfCoordinator,     // VRF协调器地址
        bytes32 _keyHash,            // VRF keyHash
        uint64 _subscriptionId       // VRF订阅ID
    )
        ERC721(name, symbol)               // 初始化NFT
        VRFConsumerBaseV2(_vrfCoordinator)  // 初始化VRF
        Ownable(msg.sender)                // 管理员为部署者
    {
        maxSupply = _maxSupply;
        price = _price;
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;

        currentPhase = SalePhase.NotStarted;  // 默认未开始销售
        saleActive = false;                   // 销售关闭
        maxPerWallet = 10;                    // 公售钱包最大购买10个
    }

    // ========================= 用户购买盲盒（核心函数） =========================
    function purchaseBox() external payable nonReentrant {
        // 校验：销售必须开启
        require(saleActive, "Sale not active");
        // 校验：付款金额足够
        require(msg.value >= price, "Insufficient payment");
        // 校验：未售罄
        require(totalSupply < maxSupply, "Sold out");
        // 校验：当前钱包购买数量未达上限
        require(balanceOf(msg.sender) < maxPerWallet, "Max per wallet reached");

        // 如果当前是白名单阶段，进行白名单校验
        if (currentPhase == SalePhase.Whitelist) {
            require(whitelist[msg.sender], "Not whitelisted");
            require(whitelistMinted[msg.sender] < whitelistMaxMint, "Whitelist mint limit reached");
            whitelistMinted[msg.sender]++;  // 白名单已 mint 数量+1
        }

        // 铸造新NFT，tokenId从0开始递增
        uint256 tokenId = totalSupply;
        totalSupply++;
        _safeMint(msg.sender, tokenId);

        // 记录盲盒信息：已购买、未开盒
        blindBoxes[tokenId] = BlindBox({
            purchased: true,
            revealed: false,
            purchaseTime: block.timestamp,
            revealTime: 0
        });

        // 向VRF请求随机数 → 用于分配稀有度、开盒
        requestRandomness(tokenId);

        emit BoxPurchased(msg.sender, tokenId);
    }

    // ========================= 向VRF请求随机数 =========================
    function requestRandomness(uint256 tokenId) internal {
        uint256 requestId = vrfCoordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        // 把请求ID和tokenID绑定
        requestIdToTokenId[requestId] = tokenId;
    }

    // ========================= VRF返回随机数（Chainlink自动回调） =========================
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // 取出对应的tokenID
        uint256 tokenId = requestIdToTokenId[requestId];
        uint256 randomness = randomWords[0];  // 拿到真随机数

        // 1. 根据随机数分配稀有度
        _assignRarity(tokenId, randomness);
        // 2. 自动开盒
        revealBox(tokenId);
    }

    // ========================= 核心：随机数分配稀有度 =========================
    function _assignRarity(uint256 tokenId, uint256 randomness) internal {
        // 随机数取模 10000 → 得到 0~9999
        uint256 randomValue = randomness % 10000;
        Rarity rarity;

        // 随机区间判定稀有度
        if (randomValue < LEGENDARY_PROBABILITY) {
            rarity = Rarity.Legendary;  // 0~299 → 传说 3%
        } else if (randomValue < LEGENDARY_PROBABILITY + EPIC_PROBABILITY) {
            rarity = Rarity.Epic;       // 300~1499 → 史诗 12%
        } else if (randomValue < LEGENDARY_PROBABILITY + EPIC_PROBABILITY + RARE_PROBABILITY) {
            rarity = Rarity.Rare;       // 1500~3999 → 稀有 25%
        } else {
            rarity = Rarity.Common;     // 4000~9999 → 普通 60%
        }

        // 保存稀有度并触发事件
        tokenRarity[tokenId] = rarity;
        emit RarityAssigned(tokenId, rarity);
    }

    // 查询NFT稀有度
    function getRarity(uint256 tokenId) public view returns (Rarity) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return tokenRarity[tokenId];
    }

    // ========================= 盲盒开盒 =========================
    function revealBox(uint256 tokenId) internal {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        require(!blindBoxes[tokenId].revealed, "Already revealed");

        // 标记为已开盒
        blindBoxes[tokenId].revealed = true;
        blindBoxes[tokenId].revealTime = block.timestamp;

        // 根据稀有度生成对应的元数据链接
        Rarity rarity = tokenRarity[tokenId];
        _setTokenURI(tokenId, _buildTokenURI(tokenId, rarity));

        emit BoxRevealed(tokenId, rarity);
    }

    // 查询盲盒状态
    function getBlindBoxStatus(uint256 tokenId)
        public
        view
        returns (bool purchased, bool revealed, Rarity rarity)
    {
        BlindBox memory box = blindBoxes[tokenId];
        return (
            box.purchased,
            box.revealed,
            box.revealed ? tokenRarity[tokenId] : Rarity.Common
        );
    }

    // ========================= 元数据（图片/JSON）相关 =========================
    // 设置基础URI（管理员）
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    // 拼接真实NFT的元数据链接

    //https://violet-immediate-cicada-846.mypinata.cloud/ipfs/bafybeidvgbvyfden5jxej3svqt2z2frtqaisaez4myhb2bd4zh55zuoqju/common/3.json
    function _buildTokenURI(uint256 tokenId, Rarity rarity)
        internal
        view
        returns (string memory)
    {
        return string(abi.encodePacked(  _baseTokenURI, "/", _rarityToString(rarity), "/", _toString(tokenId),".json"));
    }

    // 设置tokenURI
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }

    // NFT市场读取图片/JSON的标准方法
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        // 已开盒 → 返回真实图片
        if (blindBoxes[tokenId].revealed) {
            return _tokenURIs[tokenId];
        }

        // 未开盒 → 返回盲盒图片
        return string(abi.encodePacked(_baseTokenURI, "/blindbox.json"));
    }

    // 稀有度转字符串（拼接链接用）
    function _rarityToString(Rarity rarity) internal pure returns (string memory) {
        if (rarity == Rarity.Common) return "common";
        if (rarity == Rarity.Rare) return "rare";
        if (rarity == Rarity.Epic) return "epic";
        if (rarity == Rarity.Legendary) return "legendary";
        return "unknown";
    }

    // 数字转字符串（拼接链接用）
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // ========================= 管理员后台控制 =========================
    // 修改价格
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    // 开启/关闭销售
    function setSaleActive(bool _active) public onlyOwner {
        saleActive = _active;
    }

    // 切换销售阶段：未开始 / 白名单 / 公售
    function setSalePhase(SalePhase _phase) public onlyOwner {
        currentPhase = _phase;
        saleActive = (_phase != SalePhase.NotStarted);
        emit SalePhaseChanged(_phase);
    }

    // 设置钱包最大购买数
    function setMaxPerWallet(uint256 _max) public onlyOwner {
        maxPerWallet = _max;
    }

    // 批量添加白名单
    function addToWhitelist(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }

    // 批量移除白名单
    function removeFromWhitelist(address[] memory addresses) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = false;
        }
    }

    // ========================= 提现（收取销售资金） =========================
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    // 标准接口支持
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}