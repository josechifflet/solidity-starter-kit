import { POSClient, use } from '@maticnetwork/maticjs';
import { Web3ClientPlugin } from '@maticnetwork/maticjs-web3';
import HDWalletProvider from '@truffle/hdwallet-provider';
import Web3 from 'web3';
import { getContractAbi } from '../utils/getAbi';

use(Web3ClientPlugin);

export class Polygon {
  web3: Web3;

  constructor() {
    this.web3 = new Web3(new Web3.providers.HttpProvider('https://rpc.ankr.com/polygon_mumbai'));
  }

  public generateWallet = () => {
    /** A random string to increase entropy. */
    const randomHex = this.web3.utils.randomHex(32);

    const account = this.web3.eth.accounts.create(randomHex);

    return account;
  };

  public mintErc1155 = async ({
    privateKey,
    fromAddress,
  }: {
    privateKey: string;
    fromAddress: string;
  }) => {
    const contractAbi = getContractAbi('FactoryERC1155');

    const walletProvider = new HDWalletProvider({
      privateKeys: [privateKey],
      providerOrUrl: 'https://rpc.ankr.com/polygon_mumbai',
    });

    const web3 = new Web3(walletProvider);
    const erc1155FactoryContract = new web3.eth.Contract(
      contractAbi,
      '0x524944c250Cb4bA208950Dbe3b207227Fd19866C',
    );

    await erc1155FactoryContract.methods.mintERC1155(2, 'Venus', 1).send({ from: fromAddress });
  };

  public getErc1155Balance = async ({
    privateKey,
    fromAddress,
  }: {
    privateKey: string;
    fromAddress: string;
    network?: 'testnet' | 'mainnet';
    version?: 'mumbai' | 'v1';
  }) => {
    const posClient = await this.getPOSClient({ privateKey, fromAddress });
    const erc1155 = posClient.erc1155('0xa07e45a987f19e25176c877d98388878622623fa');
    const balance = erc1155.getBalance('0xE633cbaD3B6c733040b532e1860F47e3209D867B', '123');
    return balance;
  };

  private getPOSClient = async ({
    privateKey,
    fromAddress,
  }: {
    privateKey: string;
    fromAddress: string;
    network?: 'testnet' | 'mainnet';
    version?: 'mumbai' | 'v1';
  }) => {
    const posClient = new POSClient();
    await posClient.init({
      network: 'testnet',
      version: 'mumbai',

      /** Ethereum */
      parent: {
        provider: new HDWalletProvider({
          privateKeys: [privateKey],
          providerOrUrl: 'https://rpc.ankr.com/eth_goerli',
        }),
        defaultConfig: { from: fromAddress },
      },

      /** Polygon */
      child: {
        provider: new HDWalletProvider({
          privateKeys: [privateKey],
          providerOrUrl: 'https://rpc.ankr.com/polygon_mumbai',
        }),
        defaultConfig: { from: fromAddress },
      },
    });

    console.log('POSClient connected');
    return posClient;
  };
}
