// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
创建一个结构体存储 用户 要求有姓名 年龄 是否激活  钱包地址

实现新增用户
修改用户
根据用户id查找用户
根据用户id修改年龄
根据用户id取消用户激活状态
查询用户是否已经激活
*/

contract UserStruct {
    
    struct User{
        string name;
        uint256 age;
        bool active;
        address wallet;
    }

    User[] users;

    //创建用户的3中方式
    function AddUser()public   {
        User memory user = User(unicode"小芳",18,true,msg.sender);
        users.push(user);
    }

    function addUser2()public {
        User memory user = User({
            name:"dong",age:18,active:true,wallet:msg.sender
        });
           users.push(user);
    }

    function addUser3()public  {
        User memory user;
        user.age=18;
        user.active=true;
        user.name="gao";
        user.wallet=msg.sender;
        users.push(user);
    }

    //根据用户id查找用户
    function getUserById(uint256 _index)external view returns (User memory) {
        return users[_index];
    }

    //查询用户是否已经激活
    function queryUserIsActive(uint256 _index)external view returns(bool) {
        return users[_index].active;
    }


    //根据用户id修改年龄
    function modifyAge(uint256 _index,uint256 _age) external  returns(User memory) {
        User storage u = users[_index];
        u.age=_age;
        return u;
    }

    function modifyAge2(uint256 _index, uint256 _age) external returns (User memory) {
        users[_index].age = _age;
        return users[_index]; // 返回已更新的 storage 数据
    }


    //根据用户id取消用户激活状态
    function modifyActive(uint256 _index)external   returns(User memory) {
        User storage u = users[_index];
        u.active=false;
        return u;
    }


    
}