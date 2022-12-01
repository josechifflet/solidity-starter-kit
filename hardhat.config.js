require('@nomicfoundation/hardhat-toolbox');
require('./tasks');
require('dotenv').config();

const MAINNET_RPC_URL = 'https://rpc.ankr.com/eth';
const GOERLI_RPC_URL = 'https://rpc.ankr.com/eth_goerli';
const POLYGON_MAINNET_RPC_URL = 'https://rpc.ankr.com/polygon';
const MUMBAI_RPC_URL = 'https://rpc.ankr.com/polygon_mumbai';

const PRIVATE_KEY = '0x78b8a3d5c44210aaea1dc7caa968d02fef5da85a3059c63a86cc031e723f27d3';

// Your API key for Etherscan, obtain one at https://etherscan.io/
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || 'Your etherscan API key';
const POLYGONSCAN_API_KEY = 'A89PKWHCMB3RNTZB1RHZT9H9FGXEFT97U9';
const MUMBAI_POLYGONSCAN_API_KEY = 'A89PKWHCMB3RNTZB1RHZT9H9FGXEFT97U9';

const REPORT_GAS = process.env.REPORT_GAS || false;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [{ version: '0.8.7' }, { version: '0.6.6' }, { version: '0.4.24' }],
  },
  networks: {
    hardhat: {
      hardfork: 'merge',
      // If you want to do some forking set `enabled` to true
      forking: {
        url: MAINNET_RPC_URL,
        enabled: false,
      },
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    mumbai: {
      url: MUMBAI_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 80001,
    },
    goerli: {
      url: GOERLI_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 5,
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 1,
    },
    polygon: {
      url: POLYGON_MAINNET_RPC_URL,
      accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
      chainId: 137,
    },
  },
  defaultNetwork: 'hardhat',
  etherscan: {
    // yarn hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
    apiKey: {
      polygon: POLYGONSCAN_API_KEY,
      polygonMumbai: MUMBAI_POLYGONSCAN_API_KEY,
      goerli: ETHERSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: REPORT_GAS,
    currency: 'USD',
    outputFile: 'gas-report.txt',
    noColors: true,
    // coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },
  contractSizer: {
    runOnCompile: false,
    only: [
      'APIConsumer',
      'AutomationCounter',
      'NFTFloorPriceConsumerV3',
      'PriceConsumerV3',
      'RandomNumberConsumerV2',
    ],
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './build/cache',
    artifacts: './build/artifacts',
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
};
