// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


//如何调用父合约的方法

event Log(string message);

contract E {
    function foo()public virtual  {
        emit Log("E.foo");
    }
    
    function bar() public virtual  {
        emit Log("E.bar");
    }
    
}

contract F is E {
    function foo()public override  virtual  {
        emit Log("F.foo");
        E.foo();
    }

    function bar() public override virtual  {
        emit Log("F.bar");
        super.bar();
    }
}

contract G is E {
    function foo()public override  virtual  {
        emit Log("G.foo");
        E.foo();
    }

    function bar() public override virtual  {
        emit Log("G.bar");
        super.bar();
    }
}


contract H is F,G {
    function foo()public virtual override  (F,G)  {
        F.foo();//指定F的foo被执行
    }

    function bar() public virtual override (F,G)  {
        emit Log("F.bar");
        super.bar();  //这种写法 F和G两个父合约的bar方法都会被执行
    }
    
}