// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract DoubleEntryPointTest -vvvv
contract DoubleEntryPointTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testDoubleEntryPointHack() public {
        /****************
         * Factory setup *
         *************** */
        DoubleEntryPointFactory doubleEntryPointFactory = new DoubleEntryPointFactory();
        ethernaut.registerLevel(doubleEntryPointFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(doubleEntryPointFactory);
        DoubleEntryPoint ethernautDoubleEntryPoint = DoubleEntryPoint(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         *
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
