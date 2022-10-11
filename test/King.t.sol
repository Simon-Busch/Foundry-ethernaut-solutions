// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/King/KingFactory.sol";
import "../src/King/KingHack.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract KingTest -vvvv
contract KingTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testKingHack() public {
        /****************
         * Factory setup *
         *************** */
        KingFactory KingFactory = new KingFactory();
        ethernaut.registerLevel(KingFactory);
        vm.startPrank(tx.origin); // need to set the prank to tx.origin
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            KingFactory
        );
        King ethernautKing = King(payable(levelAddress));

        /****************
         *    Attack     *
         *************** */
        KingHack KingHack = new KingHack(levelAddress);
        //In the hack contract, in attack function, we need to pass a msg.value
        // calling the receive of the base contract
        // In order to claim ownership, we either need a value >= prize or be the owner
        KingHack.attack{value: 1 ether}();

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
