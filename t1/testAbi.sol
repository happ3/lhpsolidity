// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    
function abiTest() public pure returns  (string memory,uint ,bool){
    // 打包
    bytes memory box = abi.encode(unicode"小明", 18, true);

// 拆包（对方收到后）
    (string memory name, uint age, bool isStudent) = abi.decode(box, (string, uint, bool));
    return (name,age,isStudent);
}

}




contract Restaurant {
    // 现在 eat 需要知道吃什么
    function eat(string calldata food) public  pure returns (string memory) {
        return string.concat("eating ", food);
    }

    function getEatAppleInstruction() public pure returns (bytes memory) {
        bytes4 selector = bytes4(keccak256("eat(string)")); // 注意签名变了！
        bytes memory instruction = abi.encodeWithSelector(selector, "apple");
        return instruction;
    }
}


contract Customer {
    function order(address restaurant)   public  {
        // 1. 先拿到“吃苹果”的指令
        bytes memory instruction = Restaurant(restaurant).getEatAppleInstruction();

        // 2. 发送给餐厅（低级调用）
        (bool success, ) = restaurant.call(instruction);

        require(success, "Order failed");
    }
}