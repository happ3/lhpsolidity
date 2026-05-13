// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
WhiteList
mapping(address => bool) public isWhitelisted
owner 可以添加 / 移除白名单
写一个只有白名单能调用的函数 doSomething()
考点：mapping + 权限组合

*/

contract WhiteList {
    mapping(address => bool) public isWhitelisted;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addWhiteList(address _addr) external   {
         require(msg.sender == owner, "not owner");
        isWhitelisted[_addr] = true;
    }

    function remove(address _addr) external  {
         require(msg.sender == owner, "not owner");
        require(isWhitelisted[_addr],"not in WhiteList");
        isWhitelisted[_addr]=false;
    }

    function doSomething(uint256 x,uint256 y) external view  returns (uint256){
        require(isWhitelisted[msg.sender],"not in WhiteList");
        return x+y;
    }


}