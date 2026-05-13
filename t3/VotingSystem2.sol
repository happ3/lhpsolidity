// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
投票系统
需求：

创建一个完整的投票系统：

支持创建多个提案
每个提案有截止时间
只有owner可以创建提案
每个地址只能投一次票
可以查询投票结果
可以获取获胜提案


下面这两种思路 都可以记录 每个提案投票是否已经投票
struct Proposal {
    mapping(address => bool) voters;
}

mapping(uint => mapping(address => bool)) public hasVoted;
*/


contract VotingSystem {
    struct Proposal {
        string description;// 提案描述（提案内容）
        uint voteCount;// 投票数量（得票数）
        uint deadline;// 截止时间（投票什么时候结束）
        bool exists;// 是否已执行（投票通过后是否已处理）
    }
    
    address public owner;
    uint public proposalCount;
    
    mapping(uint => Proposal) public proposals;
    mapping(uint => mapping(address => bool)) public hasVoted;
    
    event ProposalCreated(uint indexed proposalId, string description, uint deadline);
    event Voted(uint indexed proposalId, address indexed voter);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }
    
    function createProposal(string memory description, uint durationDays) 
        public onlyOwner 
    {
        require(bytes(description).length > 0, "Empty description");
        require(durationDays >= 1 && durationDays <= 30, "Invalid duration");
        
        uint proposalId = proposalCount++;
        uint deadline = block.timestamp + (durationDays * 1 days);
        
        proposals[proposalId] = Proposal({
            description: description,
            voteCount: 0,
            deadline: deadline,
            exists: true
        });
        
        emit ProposalCreated(proposalId, description, deadline);
    }
    
    function vote(uint proposalId) public {
        require(proposals[proposalId].exists, "Proposal does not exist");//判断提案是否存在
        require(block.timestamp <= proposals[proposalId].deadline, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        hasVoted[proposalId][msg.sender] = true;
        proposals[proposalId].voteCount++;
        
        emit Voted(proposalId, msg.sender);
    }
    
    function getWinner() public view returns (uint winningProposalId) {
        uint maxVotes = 0;
        
        for (uint i = 0; i < proposalCount; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
        
        return winningProposalId;
    }
    
    function getProposalInfo(uint proposalId) 
        public view 
        returns (
            string memory description,
            uint voteCount,
            uint deadline,
            bool hasEnded
        ) 
    {
        require(proposals[proposalId].exists, "Proposal does not exist");
        
        Proposal memory p = proposals[proposalId];
        return (
            p.description,
            p.voteCount,
            p.deadline,
            block.timestamp > p.deadline
        );
    }
}