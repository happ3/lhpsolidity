// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/***
合约名称：CrowdfundingTracker
业务场景
    去中心化众筹平台

解读
    1，设定目标金额
    2，设定结束时间
    3，记录已经募集金额
    4，记录每个人的出资金额
    5，目标达成时发起人可以提现
    6，目标时间内未达成时出资人可以退款

方法
1众筹方法
2提现方法
3退款方法
4查看募集金额
5启动活动    


得到3个收获
1，用 require 拦截，不要用 if + return
2，如果设置状态，那么每一个状态都要有赋值，如果没有赋值需要检查一下
3，如果设置状态，那么每一方法调用时都要考虑是否要加状态的判断

/**
if(status != None){
    return true;
}
但是！
如果有人直接转账 ETH 强行把 status 改成 Success
或者 合约出现异常，status 被重置
你的 start() 函数 又可以重新执行了
又能重新设置目标金额、重新设置结束时间！

最终结论：
你的理解是对的！
if(status != None) return true;
确实能阻止重复初始化
但行业标准、安全规范、最佳实践都要求：
用 require 拦截，不要用 if + return
*/

contract CrowdfundingTracker {

    enum CrowdStatus {None, Pending,Success,Fail } 
    //目标金额
    uint256 public tragetTotalMoney;

    uint256 public currentMoney;
    
    mapping (address=>uint256) userCrodMoney;
    

    uint256 endTime;

    //活动持续时间
    uint256 tragetTime;

    address private owner;

    CrowdStatus status;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(owner==msg.sender, "not owner");
        _;
    }

    //活动未结束
    modifier haveNotOvered{
   
        require(block.timestamp > endTime, "have not overed");
        _;
    }
    //活动已结束
    modifier alreadyOver{
        require(block.timestamp <= endTime, "already over");
        _;
    }

    //余额不足
    modifier insufficientFunds {
        require(userCrodMoney[msg.sender]>0, "not sufficient funds");
        _;
    }
    //募集金额未达成
    modifier notEach {
        require(false, "not reach");
        _;
    }

    event FundEvent(address indexed user,uint256 amount);
    event RefundEvent(address indexed user,uint256 amount);
    event Withdraw(address indexed user,uint256 amount);
    event StartEvent(address indexed user ,uint256 amount);


    function start(uint256 _tragetTotalMoney,uint256 _tragetTime) external onlyOwner returns (bool){
        require(status == CrowdStatus.None, "already started");
        status = CrowdStatus.Pending;
        tragetTotalMoney = _tragetTotalMoney;
        tragetTime = _tragetTime;
        endTime = tragetTime + block.timestamp;
        emit StartEvent(msg.sender,_tragetTotalMoney);
        return true;
    }

    function fund() external payable alreadyOver {
        require(status != CrowdStatus.None, unicode"活动尚未开始");
        require(msg.value>0, unicode"金额必须大于0");
        userCrodMoney[msg.sender] += msg.value;
        currentMoney += msg.value;
        if (currentMoney>=tragetTotalMoney){
            status = CrowdStatus.Success;
        }
        emit FundEvent(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner haveNotOvered{
        require(status == CrowdStatus.Success, unicode"活动未成功");//？？
        require(address(this).balance >= tragetTotalMoney, unicode"募集金额未达标不能提现");
        (bool success,) = payable (msg.sender).call{value: address(this).balance}("");
        require(success, "withdraw fail");
        emit Withdraw(msg.sender,address(this).balance);
    }


    function refund() external haveNotOvered insufficientFunds{
        if(currentMoney < tragetTotalMoney){   //缺少一个状态赋值
            status = CrowdStatus.Fail;
        }
        require(status == CrowdStatus.Fail, "can not refund");//？？
        uint256 userBalance = userCrodMoney[msg.sender];
        userCrodMoney[msg.sender] = 0;

        (bool success,) = payable (msg.sender).call{value: userBalance}("");
        require(success, "refund fail");

        status = CrowdStatus.Fail;
        emit RefundEvent(msg.sender, userBalance);
    }

}