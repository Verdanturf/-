import { ethers } from "hardhat";

async function main() {
  const EasyBet = await ethers.getContractFactory("EasyBet");
  const easyBet = await EasyBet.deploy();
  await easyBet.deployed();
  console.log(`✅ EasyBet deployed to: ${easyBet.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
