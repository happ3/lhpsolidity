// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



/***
SimpleVote.sol
简易投票合约
一人一票
只有 owner 可以开启投票
用户投 支持/反对，合约统计结果

*/

contract SimpleVote {
    uint256 public tatalTicket;

    address public owner;
    bool public pauseStatus;

    uint256 public right;
    uint256 public worng;

    mapping (address=>bool) public onlyVote;


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "not owner");
        _;
    }
    modifier oncesVote{
        require(!pauseStatus, "The event has been suspended.");
        require(!onlyVote[msg.sender], "already vote");
        _;
     
    }
    


    function pause() external onlyOwner{
        pauseStatus = true;
    }

    function unpause() external onlyOwner{
        pauseStatus = false;
    }



    //支持
    function RigntVote()external  oncesVote{
        onlyVote[msg.sender] = true;
        right +=1;
    }


    //反对
    function WrongVote()external  oncesVote{
        onlyVote[msg.sender] = true;
        worng +=1;
    }

    function getTotalVote()external view returns (uint256) {
        return right + worng;
    }

}