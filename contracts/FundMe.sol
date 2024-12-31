// This contract will be able to:
// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
// Pragma statement
pragma solidity ^0.8.8;
//Import statements
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
import "hardhat/console.sol";
// Error codes
error FundMe__NotOwner();
error FundMe__InsufficientFunds();
error FundMe__NoWithdraw();

// contract execution cost = 860,119 gas
// 840,571
// Smart contracts can hold native tokens just like wallet address

// Interfaces, libraries, contracts

/**
 *  @title A contract for crowdfunding
 *  @author Dunayo
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // uint256 public price = PriceConverter.getPrice();
    // 'constant' and 'immutable' are gas optimization keywords
    // State variables!
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    // 	351 gas - constant | 351 * 33197000000 = $0.04
    //  2451 gas - non-constant | 2451 * 33197000000 = $0.31

    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner;
    // 444 gas - immutable
    // 2,580 gas - non-immutable

    AggregatorV3Interface private s_priceFeed;

    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");
        // this line of code is more gas efficient than the code above
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions Order"
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    // 'constructor()' is a special function that does
    // not require the function keyword
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
        // console.log("Owner:", i_owner);
    }

    // what happens if someone sends ETH to this contract
    // without calling the fund function?
    // 'receive()' and 'fallback()' are special functions
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // DEBUGGING & GETTING HELP
    // Limit tinkering and triaging to 20 minutes
    // Take at least 15 minutes yourself -> or be 100% sure
    // that you exhausted all options before moving on

    // 1. Tinker and try to pinpoint what exactly is going on
    // 2. Google the exact error
    // 2.5 Go to the course's github repo discussions and/or updates
    // 3. Ask a question on a forum like Stack Exchange ETH and Stack Overflow

    /**
     * @notice This function funds the contract
     * @dev This implements price feed as our library
     */
    function fund() public payable {
        // Setting a minimum fund amount in USD
        // How do we send ETH to this contract?
        // msg.value.getConversionRate() is the same as getConversionRate(msg.value)
        // msg.value is considered as the first argument of the library function
        // if a second argument exists, then it would be passed inside the parentheses
        // require(
        //     msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
        //     "Didn't send enough funds baby!"
        // ); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
        /// @dev One gas optimization technique is to use revert instead of require
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD)
            revert FundMe__InsufficientFunds();
        // msg.value has 18 decimal places
        // revert refers to undoing an action and returning gas
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        // console.log("Glad to receive your money -:)");
    }

    function withdraw() public payable onlyOwner {
        // console.log("Withdrawing funds, please wait...");
        /* starting index, condition, increment */
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            // code
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset s_funders array
        s_funders = new address[](0);

        // actually withdraw the funds
        // the three methods to send ethereum are transfer, send and call
        // transfer
        // msg.sender is of type 'address'
        // payable(msg.sender) is of type 'payable address'
        // which enables exchange of ethereum
        // payable(msg.sender).transfer(address(this).balance);
        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed.");
        // call
        (bool callSuccess /*bytes memory dataReturned*/, ) = payable(msg.sender)
            .call{value: address(this).balance}("");
        // require(callSuccess, "Call failed.");
        if (!callSuccess) revert FundMe__NoWithdraw();
        // 'revert' keyword performs the same function as require
        // without the condition argument
        // revert();
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory, sorry!
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
        if (!success) revert FundMe__NoWithdraw();
    }

    // View/Pure functions
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

// Enums
// Events
// Try / Catch
// Function Selectors
// abi.encode / decode
// Hashing
// Yul / Assembly
