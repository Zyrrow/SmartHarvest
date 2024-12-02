// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import  {Vault} from "src/core/Vault.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";




contract DeployVault is Script {
    address tokenAddress;
    address[] public priceFeedAddresses;

    function run() public {
        HelperConfig config = new HelperConfig();
        (address usdcAddress, uint256 deployerKey) = config.activeNetworkConfig();

        vm.startBroadcast();
        Vault vault = new Vault(usdcAddress);
        vm.stopBroadcast();
        
    }
}
