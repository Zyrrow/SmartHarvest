// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {Vault} from "src/core/Vault.sol";
import {Test} from "lib/forge-std/src/Test.sol";


contract vaultTest is Test {
    Vault vault;
    ERC20Mock  mock;
    address user = makeAddr("user");
    uint256 fundMinted = 100*10e6;
    uint256 fund = 100;
    uint256 amountToWithdraw = 5;
    uint256 userUSDCBalance;
    uint256 vaultUserBalance ;
    uint256 userShares;

    function setUp() public {

        mock = new ERC20Mock();
        vault = new Vault(address(mock));
        
        mock.mint(user, fundMinted);
        userUSDCBalance = mock.balanceOf(user);
        vaultUserBalance = mock.balanceOf(address(vault));
        userShares = vault.userShares(user);
        
    }

    function testDepositAreWorking() public { 
        vm.startPrank(user);
        mock.approve(address(vault), fund);
        vault.depositFund(fund);
        vm.stopPrank();
        
        assert(mock.balanceOf(user) == fundMinted - fund);
        assert(vault.userShares(user) ==  fund);
        assert(mock.balanceOf(address(vault)) == fund);
    }
    

    function testWithdrawAreWorking() public {
        vm.startPrank(user);
        mock.approve(address(vault), fund);
        vault.depositFund(fund);
        vault.withdrawFund(amountToWithdraw);
        vm.stopPrank();

        assert(vault.userShares(user) == fund - amountToWithdraw);
        assert(mock.balanceOf(user) == fundMinted - fund + amountToWithdraw);
        assert(mock.balanceOf(address(vault)) ==  fund - amountToWithdraw);
        
    }

}