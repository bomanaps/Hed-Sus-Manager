const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  let txHash, txReceipt;

  const HedManager = await hre.ethers.getContractFactory("HedManager");
  const hedmanager = await HedManager.deploy();

  await hedmanager.deployed();

  txHash = hedmanager.deployTransaction.hash;
  txReceipt = await ethers.provider.waitForTransaction(txHash);
  let hedmanagerAddress = txReceipt.contractAddress;

  console.log("hedmanager contract address", hedmanagerAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
