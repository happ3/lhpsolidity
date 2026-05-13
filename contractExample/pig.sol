// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//小猪存钱罐  
/**
这个业务什么意思呢，就是有收款存钱的入口，当用户需要用钱时，就把存钱罐打破，取出钱，就等同于把体现，然后销毁合约

selfdestruct不建议使用后

更好的替代方案：
暂停机制 (Pausable)：与其销毁，不如添加一个 pause() 函数，永久冻结合约功能。
迁移模式 (Migration)：对于可升级合约，直接切换逻辑合约地址，旧合约自然废弃，无需销毁。
所有权放弃：将 Owner 转让给 address(0) 或一个黑洞地址，让合约变成“无人管理”状态，实际上等同于功能废弃。

*/

contract PigMoney {
    address public owner;

    // ✅ 定义事件：存钱（转入ETH）
    event Deposited(address indexed user, uint256 amount);
    // ✅ 定义事件：取钱（提现ETH）
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // 接收ETH → 触发 Deposit 事件
    receive() external payable {
        emit Deposited(msg.sender, msg.value); // ✅ 存钱就广播
    }

    function withdraw() external {
        require(msg.sender == owner, "not owner");
        uint balance = address(this).balance;
        (bool result, ) = payable(msg.sender).call{value: balance}("");
        require(result, "transfer fail");
        
        emit Withdrawn(msg.sender, balance); // ✅ 取钱就广播
    }
}