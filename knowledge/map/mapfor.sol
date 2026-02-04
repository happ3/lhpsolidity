// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//map迭代

contract Demo {
    mapping(address => uint256) public balances;
    // 用于检查:地址是否已经存在于 balancesKey
    mapping(address => bool) public balancesInserted;
    address[] public balancesKey; // 所有地址

    // 设置
    function set(address ads_,uint256 amount_) external{
        balances[ads_] = amount_;
        // 1.检查
        if(!balancesInserted[ads_]){
            // 2.修改检查条件
            balancesInserted[ads_] = true;
            // 3.正在的操作
            balancesKey.push(ads_);
        }
    }
    // 获取
    function get(uint256 index_) external view returns(uint256){
        require(index_<balancesKey.length,"index_ error");
        return balances[balancesKey[index_]];
    }
    // 获取所有
    function totalAddress() external view returns(uint256){
        return balancesKey.length;
    }

    // 获取第一个值
    function first() external view returns(uint256){
        return balances[balancesKey[0]];
    }
    // 最后一个值
    function latest() external view returns(uint256){
        return balances[balancesKey[balancesKey.length-1]];
    }
}