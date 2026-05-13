// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/***
3. ManagerList.sol
    owner 可以添加 / 删除管理员
    普通用户只能查询，不能修改
    管理员可以调用特定管理函数



总结过程  错了判断
1，用户不存在不能删除
2，用处已存在不能添加
3，必须是Admin才能调用  

*/

contract ManagerList {
    
    enum Role {None,Owner, Admin,User }
    mapping (address =>Role) public rolesMap;

    address private owner;

    constructor() {
        owner = msg.sender;
        rolesMap[owner] = Role.Owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }


    modifier onlyAdmin(){
        require(rolesMap[msg.sender] == Role.Admin, "not admin");
        _;
    }

    modifier notExtist(address _addr){
        require(rolesMap[_addr] == Role.None, unicode"用户已经存在");
        _;
    }

   modifier isExtist(address _addr){
        require(rolesMap[_addr] != Role.None, unicode"用户不存在");
        _;
    }


    //owner 可以添加
    function AddAdmin(address _addr)external  onlyOwner notExtist(_addr){
        rolesMap[_addr] = Role.Admin;
    }
    //owner删除管理员 删除管用户
    function removeUser(address _addr) external onlyOwner isExtist(_addr){
        rolesMap[_addr] = Role.None;
    }
    //owner 可以添加用户
    function AddUser(address _addr) external onlyOwner  notExtist(_addr){
         rolesMap[_addr] = Role.User;
    }

    //普通用户只能查询，不能修改
    function getRole(address _addr) external view  returns (Role) {
        return rolesMap[_addr];
    }

    //管理员可以调用特定管理函数
    function onlyAdminUse()external view onlyAdmin returns (address) {
        return owner;
    }

}