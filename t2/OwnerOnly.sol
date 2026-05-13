// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
合约 OwnerOnly
部署者是 owner
写一个函数 changeOwner(address newOwner)
只有 owner 能调用，否则报错
用 require() 判断
*/
contract OwnerOnly {
    address private owner;

    constructor() {
        owner = msg.sender;
    }
    
    function changeOwner(address  _addr) external {
        require(owner==msg.sender, "not owner");
        owner = _addr;
    }

}