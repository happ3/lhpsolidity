// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
要求：
写一个合约 SimpleStorage
有一个状态变量 uint256 public number
写一个函数 setNumber(uint256 _num) 可以修改它
不用任何权限，谁都能改
*/

contract SimpleStorage {
    
    uint public number;

    function setNumber(uint _num) external   returns  (uint) {
        number =_num;
        return number;
    }

}