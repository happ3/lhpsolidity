// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在锁定期内，达到目标值，生产商可以提款
// 4. 在锁定期内，没有达到目标值，投资人在锁定期以后退款

contract FundMe  {
    
    enum FundStatus{
        going,
        success,
        fail
    }

    FundStatus public  fundStatus;

    address erc20Addr;

    mapping (address =>uint256) public balanceOf;

    uint256 public totalMoney;

    uint256 public targetMonet;

    uint256 endTime;

    address public owner;

    constructor(uint256 _targetMonet,uint256 _time) {
        owner = msg.sender;
        fundStatus = FundStatus.going;
        targetMonet = _targetMonet;
        endTime = block.timestamp + _time;
    }

    function FundMoney() external payable {
        require(msg.value > 0,unicode"金额必须大于0");
        require(block.timestamp<endTime, unicode"活动时间已经结束");
        if(fundStatus ==  FundStatus.success){
            revert(unicode"众筹金额已经达标");
        }
        balanceOf[msg.sender] += msg.value;
        totalMoney +=  msg.value;
        if(totalMoney >= targetMonet){
            fundStatus = FundStatus.success;
        }
    }


    function getFundStatus()external view  returns (FundStatus) {
        return fundStatus;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Only owner can withdraw");
        _;
    }

    modifier checkTime{
        require(block.timestamp >=endTime, unicode"活动时间还未结束");
        _;
    }

    function Withdraw()external onlyOwner checkTime returns  (bool) {
        require(totalMoney >= targetMonet, unicode"目标金额未达成");
        (bool result,)= payable (msg.sender).call{value: address(this).balance}("");
        require(result, "transfer fail");
        return true;
    }

    function refund() external checkTime {
        require(totalMoney < targetMonet, unicode"目标金额已达成");
        require(balanceOf[msg.sender]>0, unicode"余额不足不能提现");

        uint256 balance =  balanceOf[msg.sender] ;
        
        balanceOf[msg.sender] = 0;

        (bool result,)=payable (msg.sender).call{value: balance}("");
        require(result, "transfer fail");
        fundStatus = FundStatus.fail;
    }


    function setFunderToAmount(address funder, uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr, "you do not have permission to call this funtion");
        balanceOf[funder] = amountToUpdate;
    }

    function setErc20Addr (address  _erc20Addr) external onlyOwner {
        erc20Addr  = _erc20Addr ;
    }

}