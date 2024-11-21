// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions



// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Vault {


//variable
address[] public strategies;
IERC20 public token;
uint256 public s_totalShares;
uint256 public s_totalDeposit;


//Constant variable
uint256 constant FEE_PERFORMANCE = 3;


//mapping
mapping(address => uint256) userBalance;
mapping(address => uint256) userShares;

event Deposit(address indexed user, uint256 indexed amount, uint256 indexed sharesToMint)
constructor(address _tokenAddress) {
    token = IERC20(_tokenAddress);
    s_totalShares = 0;
}

/**
 * @dev Allows a user to deposit tokens into the vault and mint shares in return.
 * 
 * This function ensures the user has approved the transfer of the specified amount of tokens
 * and then performs the transfer from the user to the vault. It calculates the number of shares
 * to mint for the user based on the amount they deposit and the current state of total shares
 * and total deposits in the vault.
 * 
 * The minted shares represent the user's proportional ownership in the vault relative to the
 * total deposit.
 * 
 * @param amount The amount of tokens the user wants to deposit into the vault.
 * Emits a {Deposit} event with the details of the deposit.
 * 
 * @dev Emits a {Deposit} event.
 */
function depositFund(uint256 amount) public payable {
    // Validate deposit amount
    require(amount > 0, 'Deposit amount must be greater than zero');
    require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");

    // Transfer tokens from the user to the vault
    bool success = token.transferFrom(msg.sender, address(this), amount);
    require(success, "Token transfer failed");

    uint256 sharesToMint;

    //  Calculate the number of shares to mint for the user
    if (s_totalShares == 0) {
        // If this is the first deposit, mint shares equal to the deposit amount
        sharesToMint = amount;
    } else {
        // Otherwise, mint shares proportionally based on the user's deposit relative to total deposits
        sharesToMint = (amount * s_totalShares) / s_totalDeposit;
    }

    // Update the user's balance and shares
    userBalance[msg.sender] += sharesToMint;
    userShares[msg.sender] += sharesToMint;

    // Update the total shares and total deposits in the vault
    s_totalShares += sharesToMint;
    s_totalDeposit += amount;

    //  Emit the Deposit event
    emit Deposit(msg.sender, amount, sharesToMint);
}


function withdrawFund() public {

}

}