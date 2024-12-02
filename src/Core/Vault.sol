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
import {AaveStrategy} from "src/Strategy/AaveStrategy.sol";

contract Vault  {


//variable
address[] public strategies;
address public usdcAddress; 
IERC20 public token;
uint256 public s_totalShares;
uint256 public s_totalDeposit;


//Constant variable
uint256 constant FEE_PERFORMANCE = 3e18;


//mapping

mapping(address => uint256) public userShares;

event Deposit(address indexed user, uint256 indexed amount, uint256 indexed sharesToMint);
event Withdraw(address indexed user , uint256 indexed amountToWithdraw);

constructor(address _usdcAddress) {
    usdcAddress = _usdcAddress;
    token = IERC20(_usdcAddress);
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
    require(address(token) == usdcAddress, "Only USDC is accepted");
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
    
    userShares[msg.sender] += sharesToMint;

    // Update the total shares and total deposits in the vault
    s_totalShares += sharesToMint;
    s_totalDeposit += amount;

    //  Emit the Deposit event
    emit Deposit(msg.sender, amount, sharesToMint);
}


/**
 * @dev Allows a user to withdraw a specified amount of tokens from the vault.
 * The amount is based on the user's shares in the vault, and the shares are burned accordingly.
 * 
 * @param amountToWithdraw The amount of tokens the user wishes to withdraw from the vault.
 * Emits a {Withdraw} event upon successful withdrawal.
 */

function withdrawFund(uint256 amountToWithdraw) public {
    // Check that the user has shares in the vault
    require(userShares[msg.sender] > 0 ," there is nothing to withdraw");

     // Calculate the maximum amount that can be withdrawn by the user
    uint256 maxAmountToWithdraw = (userShares[msg.sender] * s_totalDeposit) / s_totalShares;
    require(amountToWithdraw <= maxAmountToWithdraw , "insuffisant balance");

    // Calculate the amount of shares to burn based on the requested withdrawal
    uint256 sharesToBurn = (amountToWithdraw * s_totalShares) /s_totalDeposit;

    // Update the user's shares and the total shares in the vault
    userShares[msg.sender] -= sharesToBurn;
    s_totalShares -= sharesToBurn;
    s_totalDeposit -= amountToWithdraw;

    // Transfer the requested amount to the user
    bool success = token.transfer(msg.sender, amountToWithdraw);
    require(success, "token transfert failed"); 

    emit Withdraw(msg.sender, amountToWithdraw);

}

function addStrategy(address strategy) external  {
    require(strategy != address(0));
    strategies.push(strategy);

}

function addFundToStrategy(uint256 amount, address strategy)  external {
    require(amount > 0, 'Deposit amount must be greater than zero');
    require(strategy != address(0), "Invalid strategy address");

    IERC20(token).approve(strategy,amount);
    AaveStrategy(strategy).deposit(amount);

    emit Deposit(msg.sender, amount);
}

function withdrawFundFromStrategy(uint256 amount, address strategy) external { 
    require(amount > 0, "Amount must be greater than 0");
    require(strategy != address(0), "Invalid strategy address");
    AaveStrategy(strategy).withdraw(amount);
}
}