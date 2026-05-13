// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 整套业务逻辑串起来（超好懂）
    项目方 (owner) 创建治理提案
    社区用户想要投票
    必须 质押少量 ETH 才能投
    → 过滤机器人、小号、恶意刷票
    一人只能一票，保证公平
    投票结束，统计最高票提案
    提案被否决 / 投票结束
    → 用户自己申请退款，拿回质押金
 
 四、一句话极简总结
质押 = 投票门槛，防恶意刷票
交钱不是消费，是押金
退款机制 = 押金原路退回，用户没损失
整体业务：区块链 DAO 社区治理投票
 
 
 * L3 进阶投票系统
 * 进阶功能：
 * 1. 管理员权限创建提案
 * 2. 质押金额投票，支持退款
 * 3. 投票结束后执行最高票提案
 * 4. 管理员可否决提案+全额退款
 * 5. 提案状态管理、防重复执行
 */
contract AdvanceVote {
    // 提案状态枚举
    enum ProposalStatus {
        Voting,     // 投票中
        Ended,      // 投票结束
        Rejected,   // 被管理员否决
        Executed    // 已执行
    }

    // 提案结构体
    struct Proposal {
        string description;     // 提案描述
        uint256 voteCount;      // 赞成票数
        uint256 deadline;       // 投票截止时间
        ProposalStatus status;  // 提案状态
    }

    // 全局变量
    address public immutable owner;
    uint256 public proposalCount;
    uint256 public constant VOTE_DEPOSIT = 0.01 ether; // 投票质押金

    // 提案映射：提案ID => 提案信息
    mapping(uint256 => Proposal) public proposals;
    // 记录用户投票：提案ID => 用户 => 是否投票
    mapping(uint256 => mapping(address => bool)) public userVoted;

    // 事件
    event ProposalCreate(uint256 indexed pid, string desc, uint256 deadline);
    event UserVote(uint256 indexed pid, address indexed user);
    event ProposalReject(uint256 indexed pid);
    event ProposalExecute(uint256 indexed pid);
    event RefundSuccess(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // 管理员修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "no permission");
        _;
    }

    // 1. 管理员创建提案
    function createProposal(string calldata desc, uint256 duration) external onlyOwner {
        require(bytes(desc).length > 0, "empty desc");
        require(duration > 0, "time error");

        uint256 pid = proposalCount;
        proposalCount++;

        proposals[pid] = Proposal({
            description: desc,
            voteCount: 0,
            deadline: block.timestamp + duration,
            status: ProposalStatus.Voting
        });

        emit ProposalCreate(pid, desc, block.timestamp + duration);
    }

    // 2. 用户质押ETH投票
    function vote(uint256 pid) external payable {
        Proposal storage p = proposals[pid];

        // 校验
        require(p.status == ProposalStatus.Voting, "not voting");
        require(block.timestamp < p.deadline, "vote end");
        require(!userVoted[pid][msg.sender], "voted already");
        require(msg.value == VOTE_DEPOSIT, "need 0.01 ETH");

        if(msg.value < VOTE_DEPOSIT){

        }

        // 投票逻辑
        p.voteCount++;
        userVoted[pid][msg.sender] = true;

        emit UserVote(pid, msg.sender);
    }

    // 3. 管理员：否决提案 + 自动给所有投票用户退款
    function rejectProposal(uint256 pid) external onlyOwner {
        Proposal storage p = proposals[pid];
        require(p.status == ProposalStatus.Voting, "cannot reject");

        p.status = ProposalStatus.Rejected;
        emit ProposalReject(pid);

        // 简化：外部自行调用退款（避免遍历Gas爆炸）
    }

    // 4. 用户主动退款（提案被否决 / 投票结束未执行）
    function refund(uint256 pid) external {
        Proposal storage p = proposals[pid];
        require(userVoted[pid][msg.sender], "not voted");
        require(
            p.status == ProposalStatus.Rejected || 
            block.timestamp > p.deadline,
            "cannot refund"
        );

        // 防止重复退款
        userVoted[pid][msg.sender] = false;

        // 退款
        (bool ok, ) = payable(msg.sender).call{value: VOTE_DEPOSIT}("");
        require(ok, "refund fail");

        emit RefundSuccess(msg.sender, VOTE_DEPOSIT);
    }

    // 5. 投票结束，自动找出最高票提案并执行
    function executeWinProposal() external {
        uint256 winPid = _getMaxVoteProposal();
        Proposal storage winP = proposals[winPid];

        require(block.timestamp > winP.deadline, "voting not end");
        require(winP.status == ProposalStatus.Voting, "already handle");

        // 修改状态为已执行
        winP.status = ProposalStatus.Executed;
        emit ProposalExecute(winPid);

        // 这里可以扩展：执行提案业务逻辑（转账、权限修改等）
    }

    // 内部：遍历获取最高票提案
    function _getMaxVoteProposal() internal view returns (uint256) {
        uint256 maxVote = 0;
        uint256 winId = 0;

        for (uint256 i = 0; i < proposalCount; i++) {
            Proposal memory p = proposals[i];
            if(p.status == ProposalStatus.Voting && p.voteCount > maxVote) {
                maxVote = p.voteCount;
                winId = i;
            }
        }
        return winId;
    }

    // 6. 查询提案完整信息
    function getProposalInfo(uint256 pid) external view returns (
        string memory desc,
        uint256 votes,
        uint256 deadline,
        ProposalStatus status
    ) {
        Proposal memory p = proposals[pid];
        return (p.description, p.voteCount, p.deadline, p.status);
    }

    // 接收ETH
    receive() external payable {}
}