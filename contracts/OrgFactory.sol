//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Organization.sol";
contract Factory{
    Organization[] public organizations;
    uint256 public orgIdCounter;

    event OrgnizationCreated(address orgAddress, uint256 id, string name);
    function createOrganization(string memory _name) external{
        uint256 _id = orgIdCounter;
        orgIdCounter++;
        Organization organization = new Organization(_id, _name);
        organizations.push(organization);
        emit OrgnizationCreated(address(organization), _id, _name);
    }
 
}
