//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract TransactionLedger {
    enum Status {
        Completed,
        InProgress,
        Rejected,
        AwaitingApproval
    }

    struct User {
        uint256 userId;
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

    struct Organization {
        uint256 orgId;
        string name;
    }

    struct Proposal {
        uint256 proposalId;
        uint256 datetime;
        address creator;
        address[] approvers;
        string question;
        string reason;
        bool isFinal;
        Status status;
        uint256 yesCounter;
        uint256 noCounter;
    }
    uint256 public trxIdCounter;
    uint256 public orgIdCounter;
    uint256 public userIdCounter;

    Organization[] orgList;
    FinanceTxn[] public financeTxns;
    mapping(uint256 => uint256) public orgTxnsTracker;

    constructor() {
        trxIdCounter = 0;
        orgIdCounter = 0;
        userIdCounter = 0;
        Organization memory masterOrg = Organization(0, "master");
        orgList.push(masterOrg);
    }

    function newFinanceTxn(uint _orgId, address[] memory _approvers, string memory _from, string memory _to, uint256 _amount, string memory _description, string[] memory _ipfsHashes) public {
        uint newId = trxIdCounter;
        trxIdCounter++;
        FinanceTxn storage txn = financeTxns.push();
        txn.id = newId;
        txn.orgId = _orgId;
        txn.datetime = 123;
        txn.creator = msg.sender;
        txn.approvers = _approvers;
        txn.from = _from;
        txn.to = _to;
        txn.amount = _amount;
        txn.description = _description;
        txn.ipfsHashes = _ipfsHashes;
        txn.status = Status.AwaitingApproval;
    }

    function getTrxNumber() public view returns(uint256) {
        return trxIdCounter;
    }
    // function changeStatus();
    
}
