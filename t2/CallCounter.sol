// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 CallCounter.sol
记录每个函数被调用的次数
只有 owner 可以清零计数器
外部可查看调用次数


结论 


msg.sig 这个是直接获取方法名称

string 转 byte4  需要通过下面这种方式
bytes4 sig = bytes4(abi.encodeWithSignature(funcName));

调用的时候
increase()
sub()

getCount("increase()")
getCount("sub()")

reset("increase()")
*/

contract CallCounter {

    address public owner;

    mapping(bytes4 => uint256) private  callCounts;

    constructor() {
        owner = msg.sender;
    }
    modifier incrementCount{
        callCounts[msg.sig] +=1;
        _;
    }

    function increase()external incrementCount {
       
    }

    function sub()external incrementCount {
       
    }


    function reset(string memory funcName)external  {
        require(msg.sender == owner,"not owner");
        bytes4 sig = bytes4(abi.encodeWithSignature(funcName));
        callCounts[sig]=0;
    }

    function getCount(string memory funcName) public view returns (uint256) {
        // 把字符串函数名 → 正确的 bytes4 签名
        bytes4 sig = bytes4(abi.encodeWithSignature(funcName));
        return callCounts[sig];
    }


    function expensiveOperation() public view returns (uint gasUsed) {
        uint gasBefore = gasleft();
        
        // 执行操作
        uint sum = 0;
        for (uint i = 0; i < 100; i++) {
            sum += i;
        }
        
        gasUsed = gasBefore - gasleft();
        return gasUsed;
    }
}