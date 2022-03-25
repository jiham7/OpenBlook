//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Organization is Initializable{
    uint256 public id;
    uint256 public balance;
    uint256 public credits;
    User[] public orgApprovers; 
    User[] public members;
    string public name;

    uint256 public trxIdCounter;
    uint256 public proposalIdCounter;

    // Proposal[] public proposals;
    mapping(uint => Proposal) public proposals;

    // FinanceTxn[] public transactions;
    mapping(uint => FinanceTxn) public transactions;


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
        uint256 amount;
        address creator;
        address[] approvers;
        string from;
        string to;
        string description;
        string[] ipfsHashes;
        Status status;
        uint256 confirmations;
    }
    
    enum VotingStatus {
        AwaitingApproval,
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
        uint256 confirmations;
    }

    function initialize(uint256 _id, string memory _name) public initializer{
        id = _id;
        name = _name;
        balance = 0;
        credits = 0;
        User memory admin = User(msg.sender, "admin", "admin");
        orgApprovers.push(admin);
        members.push(admin);
    }
    // constructor(uint256 _id, string memory _name) {
    //     id = _id;
    //     name = _name;
    //     balance = 0;
    //     credits = 0;
    //     User memory admin = User(msg.sender, "admin", "admin");
    //     orgApprovers.push(admin);
    //     members.push(admin);
    // }

    event TxnCreated(uint256 id, string to, string from);
    function createFinanceTxn(address[] memory _approvers, string memory _from, string memory _to, uint256 _amount, string memory _description, string[] memory _ipfsHashes) public returns(uint256){
        uint256 newId = trxIdCounter;
        trxIdCounter++;
        transactions[newId] = FinanceTxn(newId, id, block.timestamp, _amount, msg.sender, _approvers, _from, _to, _description, _ipfsHashes, Status.AwaitingApproval, 0);
        // FinanceTxn storage txn = transactions.push();
        // txn.id = newId;
        // txn.datetime = block.timestamp;
        // txn.creator = msg.sender;
        // txn.approvers = _approvers;
        // txn.from = _from;
        // txn.to = _to;
        // txn.amount = _amount;
        // txn.description = _description;
        // txn.ipfsHashes = _ipfsHashes;
        // txn.status = Status.AwaitingApproval;
        emit TxnCreated(newId, _to, _from);
        return newId;
    }
    
    
    //
    event ChangeTxnStatus(uint256 _id, string _status);
    function changeTxnStatus(uint256 _id, string memory _status) public {
        // TODO: mapping of transactionId => transaction struct
        // input as id instead of entire struct
        require(keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("InProgress")) || keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Rejected")), "Wrong input");
        if(keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("InProgress"))) {
            require(isTxnApproved(_id),"Txn not approved");
            transactions[_id].status = Status.InProgress;
        }
        else if(keccak256(abi.encodePacked(_status)) == keccak256(abi.encodePacked("Rejected"))) {
            transactions[_id].status = Status.Rejected;
        }
        else {
            transactions[_id].status = Status.Completed;
        }
        emit ChangeTxnStatus(id, _status);
    }

    event ProposalCreated(uint256 id, address creator, string question);
    function createProposal(address[] memory _approvers, string calldata _question, string memory _reason, string memory _description, string[] memory _ipfsHashes) public {
        uint256 newId = proposalIdCounter;
        proposalIdCounter++;
        // Proposal storage proposal = proposals.push();
        proposals[newId] = Proposal(newId, _description, block.timestamp, msg.sender, _approvers, _question, _reason, false, VotingStatus.AwaitingApproval, Status.AwaitingApproval, 0, 0, _ipfsHashes, 0);
        // proposal.id = newId;
        // proposal.datetime = block.timestamp;
        // proposal.creator = msg.sender;
        // proposal.approvers = _approvers;
        // proposal.question = _question;
        // proposal.reason = _reason;
        // proposal.description = _description;
        // proposal.isFinal = false;
        // proposal.votingStatus = VotingStatus.AwaitingApproval;
        // proposal.ipfsHashes = _ipfsHashes;
        // proposal.status = Status.AwaitingApproval;
        // proposal.yesCounter = 0;
        // proposal.noCounter = 0;
        emit ProposalCreated(newId, msg.sender, _question);
    }

    event AddMember(string firstName, string lastName);
    function addMember(string memory _firstName, string memory _lastName) public {
        User storage user = members.push();
        user.firstName = _firstName;
        user.lastName = _lastName;
        user.userAddress = msg.sender;
        emit AddMember(_firstName, _lastName);
    }

    function approveTransaction(uint256 _txnId) public{
        require(isApprover(_txnId), "Caller is not an approver");
        transactions[_txnId].confirmations++;
    }

    function isApprover(uint256 _txnId) public view returns(bool){
        for(uint i=0; i<transactions[_txnId].approvers.length; i++) {
            if(msg.sender == transactions[_txnId].approvers[i]) {
                return true;
            }
        }
        return false;
    }

    function isTxnApproved(uint256 _txnId) public view returns(bool){
        if(transactions[_txnId].confirmations == transactions[_txnId].approvers.length) {
            return true;
        }
        return false;
    }

    function getTxnStatus(uint256 _txnId) public view returns(string memory){
        if(transactions[_txnId].status == Status.AwaitingApproval) {
            return "AwaitingApproval";
        }
        else if(transactions[_txnId].status == Status.InProgress) {
            return "InProgress";
        }
        else if(transactions[_txnId].status == Status.Rejected) {
            return "Rejected";
        }
        return "Completed";
    }


    // function getTxn(uint256 _id) public view returns(uint256,
    //     uint256,
    //     uint256,
    //     uint256,
    //     address,
    //     address[],
    //     string,
    //     string,
    //     string,
    //     string[]){
    //     return (
    //         transactions[_id].id,
    //         transactions[_id].orgId,
    //         transactions[_id].datetime,
    //         transactions[_id].amount,
    //         transactions[_id].creator,
    //         transactions[_id].approvers,
    //         transactions[_id].from,
    //         transactions[_id].to,
    //         transactions[_id].description,
    //         transactions[_id].ipfsHashes,
    //         transactions[_id].status,
    //     );
    // }
    // function equals(FinanceTxn memory _first, FinanceTxn memory _second) pure public returns (bool) {
    //     return(keccak256(abi.encodePacked(_first.id, _first.orgId)) == keccak256(abi.encodePacked(_second.id, _second.orgId)));
    // }

    // function equals(FinanceTxn memory _first, FinanceTxn memory _second) pure public returns (bool) {
    //     return(keccak256(abi.encodePacked(_first.id, _first.orgId)) == keccak256(abi.encodePacked(_second.id, _second.orgId)));
    // }
}
