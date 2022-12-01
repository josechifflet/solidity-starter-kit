import App from './express';

import { Polygon } from './resources/polygon';

const PORT = 3000;
(async () => {
  try {
    const app = App();

    const p = new Polygon();

    const balance = await p.getErc1155Balance({
      privateKey: '0x78b8a3d5c44210aaea1dc7caa968d02fef5da85a3059c63a86cc031e723f27d3',
      fromAddress: '0xE633cbaD3B6c733040b532e1860F47e3209D867B',
    });
    console.log('getErc1155Balance', balance);

    await p.mintErc1155({
      privateKey: '0x78b8a3d5c44210aaea1dc7caa968d02fef5da85a3059c63a86cc031e723f27d3',
      fromAddress: '0xE633cbaD3B6c733040b532e1860F47e3209D867B',
    });

    app.listen(PORT, () => console.log(`Server is listening on ${PORT}`));
    console.log(`NODE ENV => ${process.env.NODE_ENV}`);
  } catch (err) {
    console.log(`CONNECTION REFUSED: ${err}`);
  }
})();
