// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

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

    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // first thing we do is set up our test environment
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
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

    function testAddFunderToArrayOfFunders() external {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunder(0), USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER); // USER is NOT OWNER so it should revert, which is is what we are expecting
        vm.expectRevert(); // next transaction should revert
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() external funded {
        // Arrange
        // Act
        // Assert

        // Arrange the test
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // uint256 gasStart = gasleft(); // builtin solidity function
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("Gas Used:", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); // have withdrawn all the funds
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawWithMultipleFunders() external funded {
        // Arrange
        uint160 numberOfFunders = 10; // 160 because it aligns with size of addresses as we are going to use numbers to generate different addresses
        uint160 startingFunderIndex = 1; // starting at 1 because sometimes address(0) reverts because of sanity checks
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax is a combination of prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0); // have withdrawn all the funds
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() external funded {
        // Arrange
        uint160 numberOfFunders = 10; // 160 because it aligns with size of addresses as we are going to use numbers to generate different addresses
        uint160 startingFunderIndex = 1; // starting at 1 because sometimes address(0) reverts because of sanity checks
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax is a combination of prank and deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); // the only difference from testWithdrawWithMultipleFunders
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0); // have withdrawn all the funds
        assertEq(startingFundMeBalance + startingOwnerBalance, fundMe.getOwner().balance);
    }
}
