// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Recovery/RecoveryFactory.sol";
import "../src/Ethernaut.sol";

contract RecoveryTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testRecoveryHack() public {
        /****************
         * Factory setup *
         *************** */
        RecoveryFactory recoveryFactory = new RecoveryFactory();
        ethernaut.registerLevel(recoveryFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(recoveryFactory);
        Recovery(payable(levelAddress));
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
