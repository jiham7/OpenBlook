//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Organization.sol";
contract Factory{
     Organization[] public organizations;

    event OrgnizationCreated(address orgAddress, uint256 id, uint256 name);

     function createOrganization(uint256 _id, string _name) external{
       Organization organization = new Organization(_id, _name);
       organizations.push(organization);
       emit OrgnizationCreated(address(organization), _id, _name);
     }
 
}
