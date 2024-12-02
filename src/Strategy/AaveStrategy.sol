// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IAToken} from "lib/protocol-v3/contracts/interfaces/IAToken.sol";
import {IPool} from "lib/protocol-v3/contracts/interfaces/IPool.sol";
import {Vault} from "src/Core/Vault.sol";

contract AaveStrategy is Vault{

    error AaveStrategy__mustBeGreaterThanZero();
    error AaveStrategy__InsuffisantFunds();

    IPool public lendingPool;
    IAToken public aToken;
    

    address public Owner;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor( address _lendingPool, address _aToken, address _token) {
        lendingPool = IPool(_lendingPool);
        aToken = IAToken(_aToken);
        token = IERC20(_token);

        Owner = msg.sender;
    }

    function deposit(uint256 amount) external {
        require (amount > 0, AaveStrategy__mustBeGreaterThanZero());

        token.transferFrom(msg.sender, address(this),amount );
        token.approve(address(lendingPool), amount);
        lendingPool.deposit(address(token) , amount , address(this) , 0);

        emit Deposited(msg.sender, amount);
    }

     function withdraw( uint256 amount) external {
         require(amount > 0,  AaveStrategy__mustBeGreaterThanZero());
        
        // Effectuer le retrait
        lendingPool.withdraw(address(token), amount, address(this));

        emit Withdrawn(msg.sender, amount);  // Assure-toi d'avoir un événement "Withdrawn"
     }
}