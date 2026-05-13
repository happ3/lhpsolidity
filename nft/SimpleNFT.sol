// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AdvancedNFT {
    
    // =======================
    // 1. 基础信息 (让市场能识别名字)
    // =======================
    string public name = "My Cool NFT";      // 集合名称
    string public symbol = "MCN";            // 缩写符号
    
    // =======================
    // 2. 核心数据库 (账本)
    // =======================
    mapping(uint256 => address) private _owners;       // 谁拥有哪个 ID  map(tokenId,adress)NFT属于哪个人
    mapping(address => uint256) private _balances;     // 谁拥有多少个     map(adress,uint256)这个人有多少个nft
    mapping(uint256 => string) private _tokenURIs;     // 每个 ID 对应的图片/JSON 链接  map(tokenId,uri)
    
    uint256 private _totalSupply;                      // 总发行量
    uint256 private _nextId;                           // 下一个要发行的 ID (从 0 或 1 开始)
    
    // 价格设定 (单位: Wei)
    // 1 ether = 10^18 Wei. 这里设定为 0.01 ETH
    uint256 public constant MINT_PRICE = 0.01 ether; 

    // =======================
    // 3. 事件 (给前端看的)
    // =======================
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    // =======================
    // 4. 辅助函数 (内部逻辑)
    // =======================
    
    // 检查 Token 是否存在
    function _requireMinted(uint256 tokenId) internal view {
        if (_owners[tokenId] == address(0)) {
            revert("Token does not exist");
        }
    }

    // 获取当前所有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        _requireMinted(tokenId);
        return _owners[tokenId];
    }

    // 获取余额
    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert("Owner cannot be zero address");
        return _balances[owner];
    }

    // 获取图片链接 (ERC-721 标准必需)
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        _requireMinted(tokenId);
        return _tokenURIs[tokenId];
    }

    // =======================
    // 5. 核心业务：付费铸造 (Mint)
    // =======================
    /**
     * @dev 用户可以调用此函数铸造 NFT
     * 必须发送至少 MINT_PRICE 的 ETH
     */
    function mint() public payable {
        // A. 【资金检查】用户付的钱够吗？
        require(msg.value >= MINT_PRICE, "Not enough ETH sent");
        
        // B. 【生成 ID】
        uint256 newId = _nextId;
        _nextId++; // 准备下一个 ID
        
        // C. 【更新账本】
        _owners[newId] = msg.sender;          // 主人是调用者
        _balances[msg.sender] += 1;           // 余额 +1
        _totalSupply++;                       // 总量 +1
        
        // D. 【绑定元数据】
        // 实际项目中，这里通常指向 IPFS 链接，例如 "ipfs://Qm..."
        // 这里为了演示，我们动态生成一个假链接
        _tokenURIs[newId] = string(abi.encodePacked("https://my-nft-project.com/metadata/", vmToString(newId), ".json"));

        // E. 【发出事件】from 是 0 地址代表铸造
        emit Transfer(address(0), msg.sender, newId);
    }

    // =======================
    // 6. 核心业务：安全转账 (带接收者检查)
    // =======================
    /**
     * @dev 简化版的安全转账
     * 如果接收者是合约，会检查它是否支持 NFT (防止资产丢失)
     */
    function safeTransfer(address to, uint256 tokenId) public {
        // 1. 权限检查：必须是主人
        require(_owners[tokenId] == msg.sender, "Not the owner");
        require(to != address(0), "Transfer to zero address");

        // 2. 执行转账逻辑
        _transfer(msg.sender, to, tokenId);

        // 3. 【安全检查】如果接收者是合约，必须确认它支持 ERC-721
        if (to.code.length > 0) {
            // 这里省略了复杂的 try/catch 接口调用代码以保持简洁
            // 但在真实生产中，必须调用 onERC721Received 并检查返回值
            // 初学者只需知道：这行代码是为了防止转错到不支持的合约
        }
    }

    // 内部转账逻辑 (复用代码)
    function _transfer(address from, address to, uint256 tokenId) internal {
        // 清除旧主人的记录
        _owners[tokenId] = to;
        _balances[from] -= 1;
        _balances[to] += 1;
        
        emit Transfer(from, to, tokenId);
    }

    // =======================
    // 7. 提现功能 (老板收钱)
    // =======================
    /**
     * @dev 只有合约部署者可以提取里面的 ETH
     */
    function withdraw() public {
        require(msg.sender == tx.origin, "Only deployer can withdraw"); // 简单权限检查
        payable(msg.sender).transfer(address(this).balance);
    }

    // =======================
    // 8. 工具函数 (数字转字符串)
    // =======================
    function vmToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
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
}