// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
需求：

创建一个完整的用户管理系统，实现以下功能：

用户注册（包含name、email）
更新个人资料
存款功能（payable）
查询用户信息
获取所有用户列表
分批查询用户
限制最多10个用户

*/

contract CompletePattern {
    
    struct UserInfo{
        string name;
        string email;
        uint256 balance;
        uint256 registeredAt;
        bool exist;
    }

    mapping (address=>UserInfo) public users;
    address[] public userAddresses;
    uint256 public userCount;
    uint256 public constant MAX_USERS = 1000;

      // 事件
    event UserRegistered(address indexed user, string name);
    event UserUpdated(address indexed user, string name);
    event Deposit(address indexed user, uint256 amount);
    

    function register(string memory _name,string memory _email) external {
        require(!users[msg.sender].exist, "is exist");
        require(userCount<MAX_USERS, "Max users reached");
        require(bytes(_name).length>0, "name required");

        users[msg.sender] = UserInfo({
            name: _name,
            email:_email,
            balance:0,
            registeredAt:block.timestamp,
            exist:true
        });

        userAddresses.push(msg.sender);
        userCount++;

        emit UserRegistered(msg.sender, _name);
    }

    function updateProfile(string memory _name, string memory _email) public {
        require(users[msg.sender].exist, "not register");
        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
        emit UserUpdated(msg.sender, _name);
    }

    function deposit () external  payable {
           require(users[msg.sender].exist, "not register");
           require(msg.value >0, "Must send ETH");
           users[msg.sender].balance +=msg.value;
           emit Deposit(msg.sender, msg.value);
    }

    function getUserInfo(address _user)external view  returns (UserInfo memory) {
         require(users[_user].exist, "not register");
         return users[_user];
    }

        // 检查用户是否注册
    function isRegistered(address _user) public view returns (bool) {
        return users[_user].exist;
    }

    function getAllUsers() external view returns (address[] memory){
        return userAddresses;
    }

    function getUserInfoBatch(address[] memory _addrs) external view returns (UserInfo[] memory){
        UserInfo[] memory userInfos = new UserInfo[](_addrs.length);
        for (uint256 i = 1;i<_addrs.length ; i++){
            userInfos[i] = users[userAddresses[i]];//????  这句是重点
        }
        return userInfos;

    }



}