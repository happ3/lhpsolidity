// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
TimeLock
记录一个 uint256 public unlockTime
构造函数设置多久后解锁
函数 withdraw() 必须等到时间到才能执行
考点：block.timestamp、时间判断
*/

contract TimeLock {
    mapping (address=>uint256) public balance;
        address public owner;

    uint256 public constant expiredTime = 10 seconds;
    uint256 public endTime;

    constructor() {

        owner = msg.sender;
        endTime = block.timestamp + expiredTime ;
    }

    function addBalance(uint256 _amonut) external {
        balance[msg.sender] =_amonut;
    }

    function withdraw() external {
        if(block.timestamp <= endTime){
            revert("The activity is not yet complete.");
        }
        balance[msg.sender] = 0 ;
    }

}