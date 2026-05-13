// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Person {
    struct State{
        string name;
        string gender;
    }


    State public state;

    function setState (string calldata _name,string calldata _gender) external {
        state.name = _name;
        state.gender = _gender;
    }

    function getName() external view returns (string memory,string memory){
        return (state.name , state.gender);
    }

function changeGender(uint256 param ) public {
    require(param == 1 || param == 0, unicode"输入有误不是数字");
    string memory myGender;
    myGender = param == 1?"fimal":"wormer";
    state.gender = myGender;
}





}