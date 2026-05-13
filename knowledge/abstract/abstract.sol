// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ===============
// 1. 抽象合约：定义代币基础结构（不能直接部署）

/**
如果抽象合约中的方法，具有方法体，那么抽象合约的子合约  可以自由选择是否要重写
如果抽象合约中的方法，不具有方法体，那么抽象合约的子合约必须重写方法，如果不重写，那么子合约必须也是一个抽象合约
*/
// ===============
abstract contract TokenBase {
    string public name;
    string public symbol;
    uint8 public decimals;

    // 状态变量：子合约可直接使用
    mapping(address => uint256) internal _balances;
    uint256 internal _totalSupply;

    // 构造函数：子合约必须调用
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    // 已实现的公共函数（子合约可继承或 override）
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    // 纯虚函数：强制子合约实现转账逻辑（带安全检查）
    function transfer(address to, uint256 amount) public virtual returns (bool);

    // 可选：定义内部钩子函数供子类扩展
    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), "Mint to zero address");
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // 事件（所有 ERC-20 必须有）
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// ===============
// 2. 具体实现：继承抽象合约并补全逻辑
// ===============
contract MyToken is TokenBase {
    // 调用父类构造函数
    constructor() TokenBase("MyToken", "MTK", 18) {
        // 部署时给创建者发 100 万枚
        _mint(msg.sender, 1_000_000 * 10**18);
    }

    // 必须实现父类的纯虚函数
    function transfer(address to, uint256 amount) 
        public 
        override 
        returns (bool) 
    {
        require(to != address(0), "Transfer to zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 可选择扩展：添加新功能
    function burn(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Burn amount exceeds balance");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}