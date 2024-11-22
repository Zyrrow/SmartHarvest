// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import  {Vault} from "src/core/Vault.sol";
import {MockV3Aggregator} from "test/mock/MockV3Aggregator.sol";
import  {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS =6;
    int256 public constant USDC_USD_PRICE = 1e6;


    struct NetworkConfig {
        address usdc;
        uint256 deployerKey;
    }
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;


    constructor() {
        if (block.chainid == 11_155_111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }

        
    }

    function getSepoliaUSDCConfig() public view  returns(NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            deployerKey: vm.envUint("PRIVATE_KEY")

        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory anvilNetworkConfig) {
        if (activeNetworkConfig.wethUsdPriceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator usdcUsdPriceFeed = new MockV3Aggregator(DECIMALS,USDC_USD_PRICE);
        ERC20Mock usdcUsd = new ERC20Mock();
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            usdcPriceFeed: address(usdcUsdPriceFeed),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });
    }
}