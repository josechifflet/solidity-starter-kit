const { ethers } = require('hardhat');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('Deploying contracts with the account:', deployer.address);

  const weiAmount = (await deployer.getBalance()).toString();

  console.log('Account balance:', await ethers.utils.formatEther(weiAmount));

  const Token = await ethers.getContractFactory('GoerliERC20Token');
  const token = await Token.deploy();

  // log the address of the Contract in our console
  console.log('Token address:', token.address);

  await run('verify:verify', {
    // address: contract.address,
    address: '0x524944c250Cb4bA208950Dbe3b207227Fd19866C',
  });
}

// run main, catch error, if any, and log in console
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
