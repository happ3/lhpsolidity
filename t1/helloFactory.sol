// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./hello.sol";

contract HelloFactory  {

    HelloWeb3 hw;

    HelloWeb3[] hws;

function createHello() public {
    hw = new HelloWeb3();
    hws.push(hw);
}

function getHelloByIndex(uint256 _index)public view  returns (HelloWeb3){
    return hws[_index];
}

function readSayHelloFromFactory(uint256 _index,uint256 _id) public view returns (string memory){
  return   hws[_index].sayHello(_id);
}


function createSayHelloWorldFromFactory(uint256 _index,string memory strString,uint256 _id)public {
       return hws[_index].sayHelloWorld(strString,_id);
}

}