// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
用户可以向合约存款
单个地址最多存款 10 ETH
超过限额则交易失败

结论
 if (address(this).balance + msg.value > limit){
    revert(unicode"最多不能超过2ETH");
}
但 Solidity 中 address(this).balance 在 payable 函数执行时，已经算上了当前转入的 msg.value！

也就是说 在调用Deposit 金额立马就进入了(address(this).balance里面  此时在加上msg.value  等于重复添加  
*/

contract MaxLimitDeposit {
    uint256 public constant limit = 10 * 10 **18; //2 ETH

    function Deposit() payable external  {
        if (address(this).balance > limit){
            revert(unicode"最多不能超过10ETH");
        }
    }

    function withdraw() external {
       (bool success,)= payable (msg.sender).call{value: address(this).balance}("");
       require(success,"fail");
    }

    function getBalance()external view  returns (uint256) {
        return address(this).balance;
    }
}