// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/CoinFlip/CoinFlipFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract CoinFlipTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testCoinFlipHack() public {
        /****************
         * Factory setup *
         *************** */
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */

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
