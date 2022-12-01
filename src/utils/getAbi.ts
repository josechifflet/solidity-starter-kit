import fs from 'fs';
import path from 'path';

export const getContractAbi = (contract: string) => {
  try {
    const dir = path.resolve(
      __dirname,
      `../../build/artifacts/contracts/${contract}.sol/${contract}.json`,
    );
    const file = fs.readFileSync(dir, 'utf8');
    const json = JSON.parse(file);
    const abi = json.abi;
    return abi;
  } catch (error) {
    console.log('error parsing abi', error);
  }
};
