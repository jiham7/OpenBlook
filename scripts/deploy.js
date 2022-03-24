const hre = require("hardhat");


async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();

  // Factory Contract Creation
  const OrganizationFactory = await hre.ethers.getContractFactory("OrgFactory");
  const orgFactory = await OrganizationFactory.deploy();
  

  await orgFactory.deployed();
  console.log("Org Factory contract deployed to: ", orgFactory.address);

  // Creator
  const ownerSigner = await ethers.getSigner(owner.address);
  const factoryContract = await ethers.getContractAt('OrgFactory', orgFactory.address, ownerSigner);
  
  // Create new Organization from Factory
  const newOrg = await factoryContract.createOrganization("ChainshotOrg");
  const newAddress = await factoryContract.getOrgAddress(0);

  console.log("Organization contract deployed to: " + newAddress);

  const orgContract = await ethers.getContractAt('Organization', newAddress, ownerSigner);

  // Transaction parameters
  const _orgId = 2;
  const _approvers = [addr1.address, addr2.address];
  const _from = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8';
  const _to = '0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc';
  const _amount = 1000;
  const _description = "testing desc";
  const _ipfsHashes = ['testImage', 'testImage2', 'testImage3'];

  // New Transaction Created
  const newTxn = await orgContract.createFinanceTxn(_approvers, _from, _to, _amount, _description, _ipfsHashes);
  console.log("New Transaction created with id 0 ");
  console.log("Approvers are: " + addr1.address + ", " + addr2.address)

  // First approver
  const signer1 = await ethers.getSigner(addr1.address);
  const myContract = await ethers.getContractAt('Organization', newAddress, signer1);
  const checkStatus1 = await myContract.getTxnStatus(0);
  console.log("Current Status:" + checkStatus1);
  const out = await myContract.approveTransaction(0);
  console.log("Txn approved by " + addr1.address);
  
  // Attempt to change Status. Not going to work
  console.log("Attemping to change Status to InProgress");
  const changeStatus1 = await orgContract.changeTxnStatus(0, "InProgress");
  
  // Second Approver
  const signer2 = await ethers.getSigner(addr2.address);
  const myContract2 = await ethers.getContractAt('Organization', newAddress, signer1);
  const out2 = await myContract2.approveTransaction(0);
  console.log("Txn approved by " + addr1.address);
  console.log("Attemping to change Status to InProgress");

  // Change Status
  const checkStatus2 = await orgContract.changeTxnStatus(0, "InProgress");
  console.log("Current Status:" + checkStatus2);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
