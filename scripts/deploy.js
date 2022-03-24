// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");


async function main() {
  const [owner, addr1, addr2] = await ethers.getSigners();
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  // Factory Contract Creation
  const OrganizationFactory = await hre.ethers.getContractFactory("OrgFactory");
  const orgFactory = await OrganizationFactory.deploy();
  

  await orgFactory.deployed();
  console.log("Org Factory contract deployed to: ", orgFactory.address);

  //Org Contract Creation
  // const orgAddress = await orgFactory.createOrganization("ChainshotOrg");
  // console.log("Organization contract deployed to: ", orgAddress);

  const Organization = await hre.ethers.getContractFactory("Organization");
  const org = await Organization.deploy(1, "ChainShot");
  
  await org.deployed();
  console.log("Org contract deployed to: ", org.address);


  const _orgId = 2;
  const _approvers = [addr1.address, addr2.address];
  const _from = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8';
  const _to = '0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc';
  const _amount = 1000;
  const _description = "testing desc";
  const _ipfsHashes = ['testImage', 'testImage2', 'testImage3'];

  const newTxn = await org.createFinanceTxn(_approvers, _from, _to, _amount, _description, _ipfsHashes);
  // console.log(newTxn);

  // First approver
  const signer1 = await ethers.getSigner(addr1.address);
  const myContract = await ethers.getContractAt('Organization', org.address, signer1);
  const checkStatus1 = await myContract.getTxnStatus(0);
  console.log(checkStatus1);
  const out = await myContract.approveTransaction(0);
  
  // Second Approver
  const signer2 = await ethers.getSigner(addr2.address);
  const myContract2 = await ethers.getContractAt('Organization', org.address, signer1);
  const out2 = await myContract2.approveTransaction(0);

  const changeStatus = await org.changeTxnStatus(0, "InProgress");

  const checkStatus2 = await myContract2.getTxnStatus(0);
  console.log(checkStatus2);


  

  // const trxCount = await org.getTrxNumber();
  // console.log("Trx count: " + trxCount);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
