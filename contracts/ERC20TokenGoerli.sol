// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// This function instantiates the contract and
// classifies ERC20 for storage schema
contract GoerliERC20Token is ERC20 {
    // Feel free to change the initial supply of 50 token
    // Keep the (10**18) unchanged as it multiplies the number we want as our supply to have 18 decimal
    uint constant _initial_supply = 50 * (10 ** 18);

    constructor() ERC20("GoerliERC20Token", "GOERLITEST") {
        _mint(msg.sender, _initial_supply);
    }
}
