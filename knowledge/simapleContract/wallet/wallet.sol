// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract EtherWallet {
    
    address payable   owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable { }


    //这里的提现是将金额转到合约的调用者  
    function withdraw(uint256 _account) external {
        require(msg.sender == owner,"caller is not owner");
        // payable(msg.sender).transfer(_account);

        // bool s = payable(msg.sender).send(_account);
        // require(s,"fail");

        (bool u ,)=payable(msg.sender).call{value: _account, gas: 2300}("");
        require(u,"fail");
    }
}

