// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract TestCall {
    string public message;
    uint public x;

    event Log(string  message);

    fallback() external  payable{ 
        emit  Log("fallback was  called ");
    }
    
    receive() external payable { }

    function foo(string memory _message,uint256 _x)external payable  returns (bool,uint) {
        message=_message;
        x=_x;
        return (true,999);
    }


}



contract Call {
    bytes public data;

    function callFoo(address _addr)external payable  {
        (bool s,bytes memory _data)=_addr.call{value: 1}(abi.encodeWithSignature("foo(string,uint256)", "call foo",123));

        require(s, "call fail");
        data = _data;
    }

    //下面是ai提供的两个方案

  // 方案2：使用 encodeWithSelector（推荐）
    function callFooWithSelector(address _addr) external payable {
        (bool s, bytes memory _data) = _addr.call{value: 1}(
            abi.encodeWithSelector(TestCall.foo.selector, "call foo", 123)
        );
        require(s, "call fail");
        data = _data;
    }
    
    // 方案3：使用 encodeCall（最安全）
    function callFooWithEncodeCall(address _addr) external payable {
        (bool s, bytes memory _data) = _addr.call{value: 1}(
            abi.encodeCall(TestCall.foo, ("call foo", 123))
        );
        require(s, "call fail");
        data = _data;
    }
}
