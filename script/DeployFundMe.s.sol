// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        // Create a new FundMe contract with the price feed address
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        // Print the address of the deployed contract
        vm.stopBroadcast();
        return fundMe;
    }
}
