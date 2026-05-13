// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
合约名 NameStorage
存一个字符串 string public userName
写 setUserName(string memory _name)
写 getUserName() 返回名字

*/
contract NameStorage {
    string private  userName;

    function setUserName(string memory _userName) external  {
        userName = _userName;
    }

    function getUserName() external view  returns (string memory){
        return userName;
    }
}