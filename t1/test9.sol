// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//枚举

contract UserState {
    enum State {
        Online //0
    , Offline   //1
    ,UnKnown }//2

    State public state;

    function get()public view returns (State) {
        return state;
    }

    function set(State _state)public  {
        state = _state;
    }

    function getStateVal() public view returns (string memory) {
        string[3] memory names =["Online","Offline","UnKnown"];
        return names[uint256(state)];
    }


function reset()public  {
    delete state;
}


}