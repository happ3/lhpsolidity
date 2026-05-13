// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
开关暂停合约（只有 owner 可开关）
bool public paused
pause() / unpause()
doSomething() 只有未暂停才能执行

*/

contract SwitchControl {
    address public owner;
    bool public pauseStatus = false;


    constructor() {
        owner = msg.sender;
    }

    function pause() external {
        require(msg.sender == owner,"not owner");
        pauseStatus = true;
    }

    function unpause()external {
        require(msg.sender == owner,"not owner");
        pauseStatus = false;
    }

    function doSomething(address _owner) external  {
        require(msg.sender == owner,"not owner");
        require(!pauseStatus, unicode"只有未暂停才能执行");
        owner = _owner;
    }
}