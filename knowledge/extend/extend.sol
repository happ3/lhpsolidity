// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//继承关系  不带参数

contract A {
    function foo() public pure virtual  returns (string memory) {
        return "A";
    }
    function bar() public pure  virtual returns (string memory) {
        return "A";
    }
    function baz()public pure returns (string memory) {
        return "A";
    }
}

contract B is A {
    function foo() public pure   override  returns (string memory) {
        return "b";
    }
    function bar() public pure virtual   override returns (string memory) {
        return "b";
    }


}

contract C is B {
        function bar() public pure    override returns (string memory) {
        return "c";
    }
}