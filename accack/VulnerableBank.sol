// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
//受害者    
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        require(msg.value > 0, "Must deposit > 0");
        balances[msg.sender] += msg.value;
    }

    // ❌ 危险！先转账，后清零 → 重入漏洞
    function withdrawAll() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0; // ← 太晚了！
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}