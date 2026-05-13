// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/***
要求：
UserMap
用 mapping(address => uint256) public balances
函数 setBalance(address _user, uint256 _amount)
函数 getBalance(address _user) 返回余额
考点：mapping 基本使用
*/

contract UserMap {
    
    mapping (address=>uint256) public balances;


    function setBalance(address _user, uint256 _amount)external  {
        balances[_user] = _amount;
    }

    function getBalance(address _user) external view returns (uint256){
        uint256 balance = balances[_user];
        return balance;
    }



}