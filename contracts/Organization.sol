//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Organization{
    uint256 public id;
    uint256 public balance;
    uint256 public credits;
    User[] public orgApprovers; 
    User[] public members;
    string public name;

    uint256 public trxIdCounter;
    uint256 public proposalIdCounter;
    uint256 public userIdCounter;

    Proposal[] public proposals;
    FinanceTxn[] public transactions;


    enum Status {
        Completed,
        InProgress,
        Rejected,
        AwaitingApproval
    }

    struct User {
        address userAddress;
        string firstName;
        string lastName;
    }

    struct FinanceTxn {
        uint256 id;
        uint256 orgId;
        uint256 datetime;
        address creator;
        address[] approvers;
        string from;
        string to;
        uint256 amount;
        string description;
        string[] ipfsHashes;
        Status status;
    }
    
    enum VotingStatus {
        WaitingApproval,
        InProgress,
        Finished
    }
    struct Proposal {
        uint256 id;
        string description;
        uint256 datetime;
        address creator;
        address[] approvers;
        string question;
        string reason;
        bool isFinal;
        VotingStatus votingStatus;
        Status status;
        uint256 yesCounter;
        uint256 noCounter;
        string[] ipfsHashes;
    }
    // maybe have mapping(uint256 orgId => transactions)
    constructor(uint256 _id, string memory _name) {
        id = _id;
        name = _name;
        balance = 0;
        credits = 0;
        User memory admin = User(msg.sender, "admin", "admin");
        orgApprovers.push(admin);
        members.push(admin);
    }

    event TxnCreated(uint256 id, string to, string from);
    function createFinanceTxn(address[] memory _approvers, string memory _from, string memory _to, uint256 _amount, string memory _description, string[] memory _ipfsHashes) public {
        uint256 newId = trxIdCounter;
        trxIdCounter++;
        FinanceTxn storage txn = transactions.push();
        txn.id = newId;
        txn.datetime = block.timestamp;
        txn.creator = msg.sender;
        txn.approvers = _approvers;
        txn.from = _from;
        txn.to = _to;
        txn.amount = _amount;
        txn.description = _description;
        txn.ipfsHashes = _ipfsHashes;
        txn.status = Status.AwaitingApproval;
        emit TxnCreated(newId, _to, _from);
    }

    event ProposalCreated(uint256 id, address creator, string question);
    function createProposal(address[] memory _approvers, string memory _question, string memory _reason, string memory _description, string[] memory _ipfsHashes) public {
        uint256 newId = proposalIdCounter;
        proposalIdCounter++;
        Proposal storage proposal = proposals.push();
        proposal.id = newId;
        proposal.datetime = block.timestamp;
        proposal.creator = msg.sender;
        proposal.approvers = _approvers;
        proposal.question = _question;
        proposal.reason = _reason;
        proposal.description = _description;
        proposal.isFinal = false;
        proposal.votingStatus = VotingStatus.WaitingApproval;
        proposal.ipfsHashes = _ipfsHashes;
        proposal.status = Status.AwaitingApproval;
        proposal.yesCounter = 0;
        proposal.noCounter = 0;
        emit ProposalCreated(newId, msg.sender, _question);
    }

    function addMember(string memory _firstName, string memory _lastName) public {
        User storage user = members.push();
        user.firstName = _firstName;
        user.lastName = _lastName;
        user.userAddress = msg.sender;
    }
}
