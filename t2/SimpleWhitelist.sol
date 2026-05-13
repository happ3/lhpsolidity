// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
题目 1：简单白名单合约（基础数组）
合约名称：SimpleWhitelist
    业务场景
    去中心化项目常用地址白名单控制早期参与资格，仅白名单内地址可参与预售 / 空投。
    需求
    合约拥有者可添加地址到白名单（数组存储）；
    实现查询白名单总人数的功能；
    实现查询指定索引的白名单地址功能；
    实现检查地址是否在白名单中的功能。
    考察点
    数组定义、元素添加、长度获取、数组遍历、元素存在性校验

**/

contract SimpleWhitelist {
    address [] whitelist;
    mapping (address =>bool) whiteMap;

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(owner==msg.sender, "not owner");
        _;
    }

    
    function AddWhitelist(address _addr)external  onlyOwner{
        require(!whiteMap[_addr],"is exist");
        whitelist.push(_addr);
        whiteMap[_addr] = true;
    }

    function getWhiteLen() external view  returns (uint256){
        return whitelist.length;
    }

    function isExist(address _addr)external view  returns (bool) {
        return whiteMap[_addr];
    }

    function findByIndex(uint256 _index)external view  returns (address){
        require(_index < whitelist.length, "Index out of bounds");
        return whitelist[_index];
    }

}