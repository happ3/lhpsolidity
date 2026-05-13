// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


/**
写一个余额存储

1，新增用户账户，并直接存入余额
2，增加指定账户余额
3，获取指定账户余额
4，减少指定账户余额

**/
contract MappingBasics  {

    mapping (address=>uint256)balancesMap;
    mapping (address=>bool)existMap;

    // 新增用户账户，并直接存入余额
    function setBalance(address _user,uint256 _val)external  {
        require(!existMap[_user],unicode"用户已经存在");
        balancesMap[_user]=_val;
        existMap[_user]=true;
    }
    //2，增加指定账户余额
    function addBalance(address _user,uint256 _val)external {
        require(existMap[_user],unicode"用户不存在！");
        balancesMap[_user] +=_val;
    }
    //获取指定账户余额
    function getAccount(address _user)external view returns (uint256) {
        require(existMap[_user],unicode"用户不存在！");
        return balancesMap[_user];
    }

/**
假设你在 Etherscan 上随便输入一个从未用过的钱包地址，查看它的 USDT 余额：
正确行为：显示 0 USDT
如果你的合约有 require：页面会报错 “用户不存在！” —— 这很糟糕！
用户只是想看看自己有没有币，结果合约说“你这个人不存在”？
其实他“存在”，只是余额为 0。
*/
function getAccountInfo(address _user) external view returns (uint256 balance, bool exists) {
    return (balancesMap[_user], existMap[_user]);
}


   //，减少指定账户余额
    function subBalance(address _user,uint256 _val)external {
     require(existMap[_user], unicode"用户不存在！");
    require(balancesMap[_user] >= _val, unicode"余额不足！"); 
        balancesMap[_user] -=_val;
    }

    
}