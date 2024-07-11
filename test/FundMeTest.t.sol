// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // Test Types
    // 1. Unit Test
    //   - Testing the code in isolation/specific part/case
    // 2. Integration Test
    //   - Testing how the code interacts with other parts of our code
    // 3. Forked test
    //   - Testing the code in a simulated real environment
    // 4. Staging test
    //   - Testing the code in a real environment that is not prouction environment

    // State Variables

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    FundMe fundMe;
    DeployFundMe deployFundMe;
    // first thing we do is set up our test environment

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give the test user some ether to test with. Some pocket money
    }

    function testMinimumDollarIsFive() external view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    // This is more of an intergation test than a unit test

    function testPriceFeedVersionIsAccurate() external view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailIsWithoutEnoughEth() external {
        vm.expectRevert();
        fundMe.fund(); // zero amount (< MINIMUM_USD). It will be reverted. It will pass because this line is failing and that's what we want
    }

    function testFundUpdatesFundedDataStructures() external {
        vm.prank(USER); // The next transaction is sent from the USER address
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}
