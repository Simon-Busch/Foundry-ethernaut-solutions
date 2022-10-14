// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Recovery/RecoveryFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract RecoveryTest -vvvv
contract RecoveryTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testRecoveryHack() public {
        /****************
         * Factory setup *
         *************** */
        RecoveryFactory recoveryFactory = new RecoveryFactory();
        ethernaut.registerLevel(recoveryFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(
            recoveryFactory
        );
        Recovery ethernautRecovery = Recovery(levelAddress);
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
