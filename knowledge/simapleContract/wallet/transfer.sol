// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract SendEther {
    constructor() payable {}

    receive() external payable { }

    function trancefer(address payable _to) external {
        _to.transfer(123);
    }

    function send(address payable _to) external   {
        bool s = _to.send(123);
        require(s, "fail");
    }





    function call(address payable _to)external  {
        (bool u,) = _to.call{value:123, gas: 2300}("");
        require(u, "call failed");
    }
    function testCallWithoutGas(address payable _to) external {
        (bool u,) = _to.call{value:123}("");
        require(u, "call failed");
    }
}

contract EtherReceive {
    event Log(uint amount,uint gas);

    receive() external payable { 
        emit Log(msg.value,gasleft());
    }
    
}