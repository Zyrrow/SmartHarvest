// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract MockUSDC {
    ERC20Mock public mockUSDC;

    function deployMock() public {
        mockUSDC = new ERC20Mock(); // 1M USDC
    }
}
