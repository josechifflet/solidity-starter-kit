const { ethers } = require('hardhat');

async function deployERC1155Factory(chainId) {
  // set log level to ignore non errors
  ethers.utils.Logger.setLogLevel(ethers.utils.Logger.levels.ERROR);

  const accounts = await ethers.getSigners();
  const deployer = accounts[0];

  // const erc1155Factory = await ethers.getContractFactory('FactoryERC1155');
  // const contract = await erc1155Factory.connect(deployer).deploy();

  // await contract.deployed();

  // console.log('Contract deployed to: ', contract.address);
  // console.log('Contract deployed by: ', deployer.address, '\n');
  // console.log('Tokens have been minted successfully!');

  await run('verify:verify', {
    // address: contract.address,
    address: '0x524944c250Cb4bA208950Dbe3b207227Fd19866C',
  });
}

module.exports = {
  deployERC1155Factory,
};
