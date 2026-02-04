// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Enum {
    enum Status {
        None,       // 0
        Pending,    // 1
        Shiped,     // 2
        Completed,  // 3
        Rejected,   // 4
        Canceled    // 5
    }

    Status public status;

    // ✅ 手动映射：把每个枚举值对应到字符串
    function getStatusString() public view returns (string memory) {
        if (status == Status.None) return "None";
        if (status == Status.Pending) return "Pending";
        if (status == Status.Shiped) return "Shiped";
        if (status == Status.Completed) return "Completed";
        if (status == Status.Rejected) return "Rejected";
        if (status == Status.Canceled) return "Canceled";
        
        // 不会走到这里，但编译器要求有返回
        revert("Unknown status");
    }

    // 或者用数组方式（更简洁）
    function getStatusStringV2() public view returns (string memory) {
        string[6] memory names = [
            "None",
            "Pending",
            "Shiped",
            "Completed",
            "Rejected",
            "Canceled"
        ];
        return names[uint256(status)];
    }

    // 其他函数保持不变
    function set(Status _status) external {
        status = _status;
    }

    function ship() external {
        status = Status.Shiped;
    }

    function reset() external {
        delete status; // 重置为 0 (None)
    }

     function getLargestValue() public pure returns (Status) {
        return type(Status).max;
    }

    function getSmallestValue() public pure returns (Status) {
        return type(Status).min;
    }
}