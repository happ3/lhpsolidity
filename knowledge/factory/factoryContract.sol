// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Account {
    address public bank;
    address public owner;

    constructor(address _owner)payable  {
        bank = msg.sender;
        owner = _owner;
    }
}

contract AccountFactory {
    Account[] public accounts;

    function createAccount(address _owner) external payable  {
        Account acc = new Account{value: 111}(_owner);
        accounts.push(acc);
    }
}


//0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  0x7603F024D7633E99a08a79655ECD666237aCfaB1