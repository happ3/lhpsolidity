// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
要求：
SimpleVault
可以往合约转 ETH（receive 或 fallback）
函数 getBalance() 返回合约总余额
owner 可以提取所有 ETH
考点：接收 ETH、提取、权限
*/

contract SimpleVault {
    
    mapping (address=>uint256) public balances;

    receive() external payable { 
        balances[msg.sender] += msg.value;
    }

    address private owner;

    constructor(){
        owner = msg.sender;
    }

    function getBalance(address _user)external view returns (uint256){
        return balances[_user];
    }

    function getBalance() external view  returns (uint256){
        return msg.sender.balance;
    }

    function withdraw() external  {
        require(msg.sender == owner, "not owner");

        uint256 amount = balances[msg.sender];
        require(amount > 0, "balance is not for withdraw");


        balances[msg.sender] = 0;

       (bool success,)= payable (msg.sender).call{value:amount}("");
       require(success, "withdraw fail");

    }

}