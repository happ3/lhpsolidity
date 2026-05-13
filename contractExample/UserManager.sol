// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//用户管理系统

/**
需要设计用户的存储结构
用户存储类型
思路
用户存在数组中
但数组没有办法直接过去下标，也没办法直接判断数组是否存在，因为遍历数组需要消耗大量gas
所以需要借助map记录下标
借助map记录值是否存在


用户的增加 
获取所有用户
获取用户数量
删除 
以及分页（指定范围查询）
检查用户是否存在（O(1)复杂度）
**/

contract Dome {
    address[] users;
    mapping(address => uint256) indexMap;
    mapping(address => bool) existUserMap;

    uint public constant MAX_USERS = 1000;
    //用户的增加
    function addUser(address _user) external {
        require(_user != address(0), "Invalid address");
        require(!existUserMap[_user], "User already exists");
        require(users.length < MAX_USERS, "Maximum users reached");

        users.push(_user);
        existUserMap[_user] = true;
        indexMap[_user] = users.length - 1;
    }

    //获取所有用户
    function findAll() external view returns (address[] memory) {
        return users;
    }
    //获取所有用户数量
    function findAllNum() external view returns (uint256) {
        return users.length;
    }

    // 检查用户是否存在（O(1)复杂度）
    function exist(address _user) external view returns (bool) {
        return existUserMap[_user];
    }

    // 删除
    /**
思路

*/

    function remove(address _user) external {
        // if(!existUserMap[_user]){
        //     "user is not exist"
        // }


        require(existUserMap[_user], "user is not exist");
        uint256 len = users.length;
        require(len > 0, "array is empty");

        uint256 last = len - 1;
        uint256 targetIndex = indexMap[_user];

        if (targetIndex != last) {
            address lastUsers = users[last];
            users[targetIndex] = lastUsers;
            indexMap[lastUsers] = targetIndex;
        }

        users.pop();
        delete existUserMap[_user];
        delete indexMap[_user];
    }

    // （指定范围查询）
    function page(uint256 start,uint256 end) external view returns (address[] memory) {
        uint256 len = users.length;
        require(start <= end , unicode"开始位置不能小于结束位置");
        require(len >= end, unicode"结束位置不能大于数组长度");

        address[] memory newUsers = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            newUsers[i-start] = users[i];
        }
        return newUsers;
    }
}
