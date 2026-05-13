// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract CallTestContract {
    
    function setX(address _arr,uint x)external  {
        TestContract(_arr).setX(x);
    }

    function getX(address arr)external view returns (uint) {
        return TestContract(arr).getX();
    }

    function setValue(address addr,uint _x)external  payable {
        TestContract(addr).setValue{value: msg.value}(_x);
    }

    function getValue(address addr)external view returns (uint,uint) {
        (uint x,uint value) = TestContract(addr).getValue();
        return (x,value);
    }


}


contract TestContract {
    uint public x;
    uint public value;

    function setX(uint _x)external {
        x= _x;
    }
    
    function getX()external view  returns (uint) {
        return x;
    }


    function setValue(uint _x) external payable {
        x=_x;
        value = msg.value;
    }

    function getValue()external view  returns (uint ,uint) {
        return (x,value);
    }
}