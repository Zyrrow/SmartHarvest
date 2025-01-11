pragma solidity 0.8.28;


import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";


contract AdminControl is AccessControl {


    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");


    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE),"only Admine authorized");
        _;
    }

    
    function grantAdmin(address account)external {
        grantRole(ADMIN_ROLE, account);

    }
    function revokeAdmin(address account) external {
        revokeRole(ADMIN_ROLE, account);
    }
}