// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GoodSamaritan/GoodSamaritanFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract GoodSamaritanTest -vvvv
contract GoodSamaritanTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
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
        *
        *  ** Wallet **
        *
        *  ** GoodSamaritan **
        *
        *  ** INotifyable **
        *
        *
        * 
        *
        * Solidity does not support direct comparison of two strings, we can do some hashing to compare their values
        */

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
