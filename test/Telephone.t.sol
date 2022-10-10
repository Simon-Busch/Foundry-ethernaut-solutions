// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Telephone/TelephoneFactory.sol";
import "../src/Telephone/TelephoneHack.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract TelephoneTest -vvvv
contract TelephoneTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testTelephoneHack() public {
        /****************
         * Factory setup *
         *************** */
        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(tx.origin); // need to set the prank to tx.origin
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        Telephone ethernautTelephone = Telephone(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        TelephoneHack telephoneHack = new TelephoneHack(levelAddress);
        // here it's quite simple we just call attack
        telephoneHack.attack();

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
