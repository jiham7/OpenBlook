//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Organization.sol";
import "./CloneFactory.sol";

contract OrgFactory is CloneFactory{
    mapping(uint256 => Organization) public organizations;
    mapping(uint256 => address) public addresses;
    uint256 public orgIdCounter;
    address public masterContract;

    constructor(address _masterContract){
         masterContract = _masterContract;
     }

    event OrgnizationCreated(address orgAddress, uint256 id, string name);
    function createOrganization(string memory _name) external returns(address){
        uint256 _id = orgIdCounter;
        orgIdCounter++;
        // Organization organization = new Organization(_id, _name);
        Organization organization = Organization(createClone(masterContract));
        organization.initialize(_id, _name);
        organizations[_id] = organization;
        addresses[_id] = address(organization);
        emit OrgnizationCreated(address(organization), _id, _name);
        return address(organization);
    }

    function updateMasterContract(address _newMaster) public {
        masterContract = _newMaster;
    }
    
    function getOrgAddress(uint256 _id) public view returns(address){
        return addresses[_id];
    }
 
}
