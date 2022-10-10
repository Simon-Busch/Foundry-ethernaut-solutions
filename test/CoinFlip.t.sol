// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/CoinFlip/CoinFlipFactory.sol";
import "../src/CoinFlip/CoinFlipHack.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract CoinFlipTest -vvvv
contract CoinFlipTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testCoinFlipHack() public {
        /****************
         * Factory setup *
         *************** */
        CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
        ethernaut.registerLevel(coinFlipFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
        CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        vm.roll(1); // Sets block.height
        // Create coinFlipHack contract
        CoinFlipHack coinFlipHack = new CoinFlipHack(levelAddress);

        // Run the attack 10 times
        for (uint i = 0; i <= 10; i++) {
            vm.roll(1 + i); // must set new block height
            coinFlipHack.attack();
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
