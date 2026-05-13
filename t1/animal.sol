// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Cat {
    uint256 public age;

    function eat() public returns (string memory) {
        age++;
        return "cat eat fish";
    }

    function sleep1() public pure returns (string memory) {
        return "sleep1";
    }
}

contract Dog {
    uint256 public age;

    function eat() public returns (string memory) {
        age += 2;
        return "dog miss you";
    }

    function sleep2() public pure returns (string memory) {
        return "sleep2";
    }
}

interface AnimalEat {
    function eat() external returns (string memory);
}

contract Animal {
    function test(address _addr) external returns (string memory) {
        AnimalEat general = AnimalEat(_addr);
        return general.eat();
    }
}