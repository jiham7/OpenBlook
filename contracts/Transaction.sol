//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Transaction {
    enum Status {
        Completed,
        InProgress,
        Rejected,
        AwaitingApproval
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

    FinanceTxn[] public financeTxns;
    // maybe have mapping(uint256 orgId => transactions)
    constructor(string memory _orgId, address[] _approvers, string _from, string _to, uint256 _amount, string _description, string[] _ipfsHashes) {
        FinanceTxn storage txn = financeTxns.push();
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function newFinanceTxn();
    function changeStatus();
    
}
