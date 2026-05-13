// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//转账

contract Bank {
    receive() external payable { }
    
    function transfer()external{
        payable (msg.sender).transfer(1 ether);
    }

    function send()external  {
          bool success = payable (msg.sender).send(1 ether);
          require(success,"send fail");
    }

    function call() external  {
        (bool success,bytes memory data) =payable (msg.sender).call{value :1 ether}("");
        string  memory d = string(data);
        require(success,      string.concat(d,"call fail"));
    }
}


contract BankUser {
    Bank bank;

    constructor(address payable _bank) {
        bank=Bank(_bank);
    }

    receive() external payable { }
    
    function transfer()external{
      bank.transfer();
    }

    function send()external  {
         bank.send();
    }

    function call() external  {
      bank.call();
    }

}

