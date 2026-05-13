// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//拍卖合约

/**
英式拍卖

业务逻辑
拍卖成功时  需要合约拥有者进行提现
参与拍卖的人，如果失败，需要提供退款入口
需要记录最后拍卖成功的人  以及出价最高的

设计思路
先记录拍卖成功的人  如果被后来人居上则记录，等拍卖结束后  在提现



**/

contract AuctionContract {
    address hightBidder;
    uint256 public bidAmount;
    uint256 endTime;
   
    address owner;
    mapping(address => uint256) public pendingReturns;

    event NewBid(address indexed bidder, uint256 amount);
    event RefundWithdraw(address indexed winner, uint256 amount);
    event Withdrawal(address indexed bidder, uint256 amount);



    constructor(uint256 _duration) {
        owner = msg.sender;
        endTime = block.timestamp + _duration;
    }

    modifier onlyOwner{
        require(owner == msg.sender, "not owner");
        _;
    }

    function bid() external payable {
        uint256 nowamount  = msg.value;

        require(block.timestamp < endTime, "the active is over");
        require(nowamount > bidAmount, "not greater than the bidAmount"); //没有大于当前最高价

        if(hightBidder != address(0)){  //如果存在旧出价人，则记录在退款中
            pendingReturns[hightBidder] = bidAmount;
        }
        if(pendingReturns[msg.sender] > 0){ //如果退款记录的出价人  重新出价  则清除退款记录
            pendingReturns[msg.sender] = 0;
        }


        hightBidder = msg.sender;
        bidAmount = nowamount;
        emit NewBid(msg.sender,nowamount);
    }


    function refundWithdraw() external {
         require(block.timestamp >= endTime, "the active is not yet over"); //活动还未结束
         uint256 balance = pendingReturns[msg.sender];

         require(balance > 0, "balance is zero");

         pendingReturns[msg.sender] = 0;

        (bool success,)=payable(msg.sender).call{value:balance}("");
        require(success, "refundWithdraw fail");
        emit RefundWithdraw(msg.sender,balance);

    }

    function ownerWithdraw() external onlyOwner{
        require(block.timestamp >= endTime, "the active is not yet over"); //活动还未结束
        require(bidAmount > 0, "Not Balance.");
    
        uint256 amount = bidAmount; 
        bidAmount = 0;

        (bool success,)=payable(msg.sender).call{value: amount}("");
        require(success, "ownerWithdraw fail");
        emit Withdrawal(msg.sender,amount);
    }

}