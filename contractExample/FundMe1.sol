// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在锁定期内，达到目标值，生产商可以提款
// 4. 在锁定期内，没有达到目标值，投资人在锁定期以后退款
// 5，防止提前卷款跑路，需要等到时间到期时才能提现

contract FundMe  {
    
   enum FundStatus{
    going,
    success,
    fail
   }

   FundStatus fundStatus;

   uint256 totalMoney;//筹款总金额

   uint256 targetMoney;//目标金额

   mapping (address => uint)balanceOf; //众筹人员地址与金额

   uint endTime;//结束时间

   address owner;

   constructor(uint256 _targetMoney,uint256 _endTime) {
        owner = msg.sender;
        targetMoney = _targetMoney;
        endTime = block.timestamp + _endTime;
        fundStatus = FundStatus.going;
   }

   function FundMeMoney  () external payable {
        if(fundStatus == FundStatus.success){revert(unicode"众筹金额已达标");}
        require(block.timestamp < endTime ,unicode"活动已经结束");
        require(msg.value >0 ,unicode"金额必须大于0");
        balanceOf[msg.sender] +=msg.value;
        totalMoney  += msg.value;
        if(totalMoney >= targetMoney){
            fundStatus = FundStatus.success;
        }
   }

    modifier onlyOwner{
        require(msg.sender == owner, "only owner");
        _;
    }
    
    modifier checkTime{
        require(block.timestamp >= endTime, unicode"活动还未结束");
        _;
    }

   function withdraw() external onlyOwner checkTime {
        if(fundStatus == FundStatus.going){revert(unicode"众筹还在进行中");}
        require(totalMoney >= targetMoney, unicode"众筹金额还未达标");
        (bool success,) = payable (msg.sender).call{value : address(this).balance}("");
        require(success, "transfer fail");
   }

   function refund() external  checkTime{
        require(totalMoney < targetMoney, unicode"众筹金额已达标");
        uint256 balance = balanceOf[msg.sender];
        require(balance>0,unicode"余额不足");

        balanceOf[msg.sender] = 0;

        (bool success,) = payable (msg.sender).call{value : balance}("");
        require(success, "transfer fail");
        fundStatus = FundStatus.fail;
   }

}