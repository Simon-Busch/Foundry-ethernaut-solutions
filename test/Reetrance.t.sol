// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testReentranceHack() public {
        /****************
         * Factory setup *
         *************** */
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            reentranceFactory
        );
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));
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
