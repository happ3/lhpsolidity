// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//继承中多个构造函数  以及 构造函数中的参数如何传递

contract S {
    string public  name;
    constructor(string memory _name){
        name=_name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

contract U is S("s"),T("t") {
    
}

contract V is S,T {
    constructor(string memory _name,string memory _text) S(_name) T(_text){

    }
}

contract W is S("s"),T { // 这边先继承谁，先执行谁的构造函数
      constructor(string memory _name,string memory _text)  T(_text){

    }
}