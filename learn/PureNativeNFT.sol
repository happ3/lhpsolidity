// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//原生的NFT智能合约，等于看了一遍源码

/**
    思考
    NFT合约
    是一个非同质化合约，什么意思呢，就是它是一个整体，无法分裂，每一个NFT都是通过支付ETH进行铸造的，
    铸造一个NFT合约需要支付一定的以太币，同样的NFT涉及转账，以及单点授权，批量授权

    表
    1，nft主表 名称name 符号code 铸造数量 以及每一个NFT的铸造价格
    2，由于nft是由id和uri组成的推衍出
    nft与用户的中间表, 即tokenId与address的关系，为什么要把tokenId放在前面，一个人可以购买多个NFT，然后每个tokenid又是唯一的，
    那么0x1:tk001 0x1:tk002  按照map的key是唯一的，不就出现覆盖了,基于这个原因，推衍出
    map(uint256 =>address)_owners
    3，每个人拥有nft的数量就需要再有一张表来记录这个关系 被称为余额表  和ECR20的余额一个逻辑  
    map(address=>uint256)_balances  
    4，nft与uri的中间表    就是tokenId和uri的一对一关系
    map(uint256=>string)_tokenURIs
    5，单点授权 将某一个tokenId授权给其他用户，通常是钱包地址 
    map(uint256=>address)_tokenApprovals
    6，批量授权 简单的讲就是NFT拥有者把自己所有的NFT授权给另一个用户
    map(address=>map(address=>bool))_operatorApprovals

    方法推衍
    构造函数 初始化nft名称与符号

    铸造NFT方法，入参(address,uri),这个uri可以存在https://app.pinata.cloud/ipfs/files或者https://console.filebase.com/ 
    操作
    1，_owners新增数据
    2，_balances新增数据
    3，_tokenURIs新增数据


*/




// =======================
// 1. 权限管理模块 (Ownable)
// =======================
// 作用：确保只有“老板”才能提现或执行特殊操作
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _checkOwner() internal view virtual {
        if (msg.sender != _owner) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    error OwnableUnauthorizedAccount(address account);
}

// =======================
// 2. 接口定义
// =======================
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// =======================
// 3. 主合约
// =======================
contract PaidNFT is Ownable {

    // --- 业务配置 ---
    uint256 public constant PRICE = 0.01 ether; // 铸造价格：0.01 ETH
    uint256 public maxSupply = 100;             // 最大供应量：100个

    // --- 基础信息 ---
    string private _name;
    string private _symbol;

    // --- 核心数据映射 ---
    mapping(uint256 => address) private _owners;       // TokenID -> 所有者
    mapping(address => uint256) private _balances;     // 地址 -> 拥有数量
    mapping(uint256 => address) private _tokenApprovals; // TokenID -> 被授权人
    mapping(address => mapping(address => bool)) private _operatorApprovals; // 所有者 -> 操作员 -> 是否授权
    mapping(uint256 => string) private _tokenURIs;     // TokenID -> 图片/元数据链接

    // --- 计数器 ---
    uint256 private _tokenIdCounter;

    // --- 事件 ---
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // --- 构造函数 ---
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // =======================
    // 核心业务：付费铸造
    // =======================
    function safeMint(address to, string memory uri) public payable {
        // 1. 检查供应量
        if (_tokenIdCounter >= maxSupply) revert("Sold out");

        // 2. 检查支付金额 (核心修改点)
        if (msg.value < PRICE) revert("Wrong amount of ETH sent");

        // 3. 铸造逻辑
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);

        // 4. 安全检查：如果接收者是合约，确保它支持 NFT
        if (to.code.length > 0) {
            _checkOnERC721Received(msg.sender, address(0), to, tokenId, "");
        }

        // 5. 转账收益 (核心修改点)   如果是记账的方式这里不需要转账
        // 直接把钱转给合约拥有者
        (bool success, ) = payable(owner()).call{value: msg.value}("");
        if (!success) revert("Transfer failed");
    }

    // =======================
    // 提现功能 (老板专用)
    // =======================
    // 如果上面的铸造函数里不直接转账，钱会留在合约里。
    // 这个函数用于把合约里积压的钱取出来。
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        if (!success) revert("Withdraw failed");
    }

    // =======================
    // ERC-721 标准函数实现
    // =======================
    
    function name() external view returns (string memory) { return _name; }
    function symbol() external view returns (string memory) { return _symbol; }
    
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        _requireMinted(tokenId);
        return _tokenURIs[tokenId];
    }

    function balanceOf(address owner) external view returns (uint256) {
        if (owner == address(0)) revert("Invalid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) revert("Nonexistent token");
        return owner;
    }

    // --- 转账逻辑 ---
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        if (to.code.length > 0) {
            _checkOnERC721Received(msg.sender, from, to, tokenId, data);
        }
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert("Insufficient approval");
        
        address owner = _owners[tokenId];
        if (owner != from) revert("Incorrect owner");
        if (to == address(0)) revert("Invalid receiver");

        delete _tokenApprovals[tokenId];

        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }

        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    // --- 授权逻辑 ---
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) revert("Not authorized");
        
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        if (operator == msg.sender) revert("Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // --- ERC-165 支持 ---
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return 
            interfaceId == 0x01ffc9a7 || // ERC-165
            interfaceId == 0x80ac58cd || // ERC-721
            interfaceId == 0x5b5e139f;   // ERC-721 Metadata
    }

    // =======================
    // 内部辅助函数
    // =======================
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _owners[tokenId];
        return (
            spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender
        );
    }

    function _requireMinted(uint256 tokenId) internal view {
        if (_owners[tokenId] == address(0)) revert("Nonexistent token");
    }

    function _checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private {
        try IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) returns (bytes4 retval) {
            if (retval != 0x150b7a02) revert("Invalid receiver");
        } catch (bytes memory reason) {
            if (reason.length == 0) revert("Invalid receiver");
            else {
                assembly { revert(add(32, reason), mload(reason)) }
            }
        }
    }
}