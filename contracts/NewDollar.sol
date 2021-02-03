// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * The New Dollar
 * You are a Solidity engineer on a team that is building a one of a kind stablecoin
 * that the world has never seen before. This stablecoin uses a very unique pattern
 * and is designed to incentivize people who own these coins to spend them
 * as fast as possible to stimulate the economy. This bank is developing a stablecoin
 * whose user balances reset anytime the bank upgrades their stablecoin smart contract.
 * This means that if the bank has an upgrade every 30 days, you no longer own these
 * stablecoins at the end of the month.
 *
 * Problem
 * Design an ERC20 compliant token where the balances reset every time you upgrade it.
 * If you own this stablecoin in January, and there is always a smart contract upgrade
 * at the end of each month, then in February, you should not own those stablecoins
 * anymore. Your token should have all ERC20 interfaces and events. You can use
 * whatever framework or version of solidity that you would like, but you cannot use
 * a framework for handling the creation of the proxy contracts. It would be great
 * to have a few tests to demonstrate functionality without having to manually run
 * through things.
 *
 * Bonus
 * Build the token so that users' balance resets automatically every 30 days
 * in addition to resetting when the smart contract upgrades. This means that
 * the balances will reset when there is a smart contract upgrade, and they will
 * reset on the 30-day schedule.
 */

contract NewDollar {

    mapping (uint256 => mapping (address => uint256)) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    mapping (address => bool) internal _minter;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _balanceKey;
    uint256 public updateTimestamp;
    uint256 public duration = 30 days;
    
    address public owner;
    address public implementation;


    constructor (address implementation_, string memory name_, string memory symbol_, uint8 decimals_) {
        implementation = implementation_;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = msg.sender;
        _minter[msg.sender] = true;
        updateTimestamp = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function upgradeImplementation(address implementation_) public onlyOwner{
        implementation = implementation_;
        _upgrade();
    }

    function _fallback(address implementation_) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _upgrade() internal {
        _balanceKey += 1;
        _totalSupply = 0;
    }

    fallback() external payable {
        _fallback(implementation);
    }

    receive() external payable {
        _fallback(implementation);
    }
}