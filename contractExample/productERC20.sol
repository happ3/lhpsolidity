// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 导入 OpenZeppelin 的标准 ERC20 实现和 Ownable 权限控制
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyGameToken
 * @dev 这是一个可发行的 ERC20 代币合约
 * - 只有所有者可以铸造新币 (Mint)
 * - 只有所有者可以销毁特定用户的币 (Burn) - 可选功能
 * - 符合所有钱包和交易所标准
 */
contract MyGameToken is ERC20, Ownable {
    
    // 构造函数：部署时自动调用
    // _name: 代币名称 (例如 "My Game Coin")
    // _symbol: 代币符号 (例如 "MGC")
    // _initialSupply: 初始供应量 (注意：这里不需要手动乘 10^18，父合约会处理)
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _initialSupply
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        // _mint 是 ERC20 内部函数，会自动处理 decimals (18位)
        // 比如传入 1000，实际铸造的是 1000 * 10^18
        _mint(msg.sender, _initialSupply * (10 ** decimals()));
    }

    /**
     * @dev 铸造新币
     * 只有合约所有者可以调用此函数
     * @param to 接收地址
     * @param amount 铸造数量 (单位：个，合约会自动转换精度)
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        _mint(to, amount * (10 ** decimals()));
    }

    /**
     * @dev 销毁调用者自己的币
     * @param amount 销毁数量
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount * (10 ** decimals()));
    }
    
    /**
     * @dev (可选) 所有者强制销毁某个地址的币
     * 慎用！通常用于严重违规惩罚
     */
    function burnFrom(address account, uint256 amount) public onlyOwner {
        _burn(account, amount * (10 ** decimals()));
    }
}