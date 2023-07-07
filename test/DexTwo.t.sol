// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testDexTwoHack() public {
        /****************
         * Factory setup *
         *************** */
        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));
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
