// SPDX-License-Identifier: MIT
// 1. Pragma
// Specifies the version of Solidity compiler to be used for this contract
pragma solidity 0.8.19;

// 2. Imports
// Importing the AggregatorV3Interface from Chainlink to fetch price data
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// Importing a custom library called PriceConverter for price conversions
import {PriceConverter} from "./PriceConverter.sol";
import {console} from "forge-std/console.sol";

// 3. Interfaces, Libraries, Contracts
// Error declaration for when a non-owner attempts an owner-restricted action
error FundMe__NotOwner();

/**
 * @title A sample Funding Contract
 * @dev This contract implements a basic funding mechanism where users can send ETH
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    // Using the PriceConverter library for all uint256 types
    using PriceConverter for uint256;

    // State variables
    // Constant representing the minimum amount of USD required to fund
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    // Address of the contract owner, set once during deployment
    address private immutable i_owner;
    // Array to store addresses of funders
    address[] private s_funders;
    // Mapping to store the amount of ETH funded by each address
    mapping(address => uint256) private s_addressToAmountFunded;
    // Instance of the AggregatorV3Interface to fetch price data
    AggregatorV3Interface private s_priceFeed;

    // Events (we have none!)

    // Modifiers
    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        // Revert the transaction if the sender is not the owner
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        // Continue with the execution of the function
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    /**
     * @dev Constructor to initialize the contract with the price feed address
     * @param priceFeed Address of the price feed contract
     */
    constructor(address priceFeed) {
        // Initialize the price feed interface
        s_priceFeed = AggregatorV3Interface(priceFeed);
        // Set the owner of the contract to the address deploying it
        i_owner = msg.sender;
    }

    /**
     * @notice Funds our contract based on the ETH/USD price
     * @dev The function converts the sent ETH to USD using the price feed and checks if it meets the minimum requirement
     */
    function fund() public payable {
        // Check if the amount of ETH sent meets the minimum USD requirement
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // Update the amount funded by the sender's address
        s_addressToAmountFunded[msg.sender] += msg.value;
        // Add the sender's address to the list of funders
        s_funders.push(msg.sender);
    }

    /**
     * @notice Withdraws all funds from the contract
     * @dev This function can only be called by the owner
     */
    function withdraw() public onlyOwner {
        // Loop through all funders and reset their funded amount to 0
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the list of funders
        s_funders = new address[](0);
        // Transfer the contract balance to the owner using call
        (bool success,) = i_owner.call{value: address(this).balance}("");
        // Require that the transfer was successful
        require(success, "Transfer failed");
    }

    /**
     * @notice A cheaper way to withdraw funds by reducing storage reads
     * @dev This function can only be called by the owner
     */
    function cheaperWithdraw() public onlyOwner {
        // Create a memory array of funders to save gas
        address[] memory funders = s_funders;
        // Loop through all funders and reset their funded amount to 0
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the list of funders
        s_funders = new address[](0);
        // Transfer the contract balance to the owner using call
        (bool success,) = i_owner.call{value: address(this).balance}("");
        // Require that the transfer was successful
        require(success, "Transfer failed");
    }

    /**
     * @notice Gets the amount that an address has funded
     * @param fundingAddress The address of the funder
     * @return The amount funded by the address
     */
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        // Return the amount funded by the given address
        return s_addressToAmountFunded[fundingAddress];
    }

    /**
     * @notice Gets the version of the price feed
     * @return The version of the price feed
     */
    function getVersion() public view returns (uint256) {
        // Return the version of the price feed contract
        return s_priceFeed.version();
    }

    /**
     * @notice Gets the address of a funder by index
     * @param index The index of the funder in the array
     * @return The address of the funder at the given index
     */
    function getFunder(uint256 index) public view returns (address) {
        // Return the address of the funder at the specified index
        return s_funders[index];
    }

    /**
     * @notice Gets the owner of the contract
     * @return The address of the owner
     */
    function getOwner() public view returns (address) {
        // Return the address of the contract owner
        return i_owner;
    }

    /**
     * @notice Gets the price feed contract
     * @return The AggregatorV3Interface instance of the price feed
     */
    function getPriceFeed() public view returns (AggregatorV3Interface) {
        // Return the instance of the price feed contract
        return s_priceFeed;
    }
}
