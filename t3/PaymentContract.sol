// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
需求：

创建一个完整的支付合约：

支持存款（deposit）
支持提款（withdraw）
支持紧急停止（pause）
Owner可以暂停/恢复合约
查询余额
限制最小存款金额

**/

contract PaymentContract {
    enum PauseStatus {UnPause, Pause }

    PauseStatus status;

    mapping (address =>uint256) balanceOf;

    address owner;

    uint256 immutable mixMoney;

    event Deposit(address indexed from,uint256 amount);

    constructor(uint256 _mixMoney) {
        owner = msg.sender;
        mixMoney = _mixMoney;
    }

    modifier onlyOwner{
        require(owner == msg.sender, "not owner");
        _;
    }

    modifier isNotPauSe{
        require(status == PauseStatus.UnPause, "is pause");
        _;
    }

    function deposit()external payable isNotPauSe {
        require(msg.value >= mixMoney,string(abi.encodePacked(unicode"最小存款金额：", mixMoney)));
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw()external isNotPauSe {
        uint256 balance = balanceOf[msg.sender] ;
        balanceOf[msg.sender] = 0;
        require(balance > 0, unicode"余额不足");
        (bool succsee,) = payable (msg.sender).call{value: balance}("");
        require(succsee, "withdraw fail");
    }

    function pause()external onlyOwner {
        status = PauseStatus.Pause;
    }

    function unPause()external onlyOwner {
         status = PauseStatus.UnPause;
    }
}