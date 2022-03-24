// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
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
  const orgAddress = await orgFactory.createOrganization("ChainshotOrg");


  const _orgId = 2;
  const _approvers = ['0xd586E9ed4f7F6bd6e49194CfaDD063431BCE3E73', '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266'];
  const _from = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8';
  const _to = '0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc';
  const _amount = 1000;
  const _description = "testing desc";
  const _ipfsHashes = ['test1', 'test2', 'test3'];

  const newTxn = await orgAddress.newFinanceTxn(_orgId, _approvers, _from, _to, _amount, _description, _ipfsHashes);
  

  const trxCount = await ledger.getTrxNumber();
  console.log("Trx count: " + trxCount);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
