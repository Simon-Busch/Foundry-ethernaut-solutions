// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/King/KingFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract KingTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testKingHack() public {
        /****************
         * Factory setup *
         *************** */
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            kingFactory
        );
        King ethernautKing = King(payable(levelAddress));
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
