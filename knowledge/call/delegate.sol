// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
//委托调用
// 两个合约  DelegateCall  TestDelegateCall
//DelegateCall中的num，sender，value  都被改变了
//TestDelegateCall中的num，sender，value  都没有改变了

//被调用的合约中TestDelegateCall 的三个属性必须和主合约的属性一致  并且布局也需要一致   但是如果是追加的形式就不会出错


contract TestDelegateCall {
    // address public owner;会导致效果是想象中的 不一致 即主合约中的三个属性值虽然被修改了，但是结果却都是错误的
    uint public num;
    address public sender;
    uint public value;
// address public owner;   追加的方式就不会

    function setVars(uint _num)external payable  {
        num = 2*_num;
        sender = msg.sender;
        value = msg.value;
    }
    
}

contract DelegateCall {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _addr,uint _num)external payable  {
       (bool s,)= _addr.delegatecall(abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num));
        require(s, "DelegateCall fail");
    }
}