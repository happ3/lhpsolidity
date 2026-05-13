// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//自毁合约
/**
1，需要检查权限，只有管理员才能触发自毁
2，自毁后，查看余额

3，接收者的合约
4，查看接受者合约的余额
5，接受者合约的提现接口

selfdestruct不能使用后
更好的替代方案：
暂停机制 (Pausable)：与其销毁，不如添加一个 pause() 函数，永久冻结合约功能。
迁移模式 (Migration)：对于可升级合约，直接切换逻辑合约地址，旧合约自然废弃，无需销毁。
所有权放弃：将 Owner 转让给 address(0) 或一个黑洞地址，让合约变成“无人管理”状态，实际上等同于功能废弃。

*/

contract SimpleSelfDestructNoLib {
    //权限
    address public owner;
    event ContractDestroyed(address indexed receiver, uint256 balance);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    receive() external payable {}

    function destory() public  {
        emit ContractDestroyed(address(this), address(this).balance);
        selfdestruct(payable (msg.sender));
    }


    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function tastCall()external pure returns (uint) {
        return 123;
    }
}

contract targetContract {
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function kill(SimpleSelfDestructNoLib s)external   {
        s.destory();
    }

    function withdrawAll() public {
        uint balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "ETH transfer failed");
    }
}
