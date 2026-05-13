// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    uint256 public  u = 123;
    string public welcome = "hello";
    string public welcome2 ="hello";

    function test () external   returns (uint256,string memory,string memory){

        uint256 x = u;
        x = 1;
    
        string storage hi1 = welcome;
        bytes(hi1)[0] = bytes1("2");
        
        string memory hi2 = welcome2;
        bytes(hi2)[0] = bytes1("2");

        return (x,hi1,hi2);

    }

function test2() public pure returns (uint256){
           bytes memory x = bytes("123");
          return  x.length;
}


function test3() public pure  returns (bool){
    string memory x ="123";
    string memory y = "123";
    return  keccak256(abi.encode(x))==keccak256(abi.encode(y));
}

function test4()public pure returns (string memory) {
    string memory x ="abc";
    string memory y = "123";
    return string.concat(x,y);
}

function test5() public pure returns (string memory) {
    string memory s = "123";
    string memory k = "abc";

    bytes memory bt1 = bytes(s);
    bytes memory bt2 = bytes(k);

   return  string(bytes.concat(bt1,bt2));

}


function test6() public pure returns(string memory)  {
    string memory s1 ="abc";
    string memory s2 = "456";
    return string(abi.encodePacked(s1,s2));
}

}