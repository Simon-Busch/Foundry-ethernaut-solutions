// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Reetrance/ReetranceFactory.sol";
import "../src/Reetrance/ReetranceHack.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract ReetranceTest -vvvv
contract ReetranceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testReetranceHack() public {
        /****************
         * Factory setup *
         *************** */
        ReetranceFactory ReetranceFactory = new ReetranceFactory();
        ethernaut.registerLevel(ReetranceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            ReetranceFactory
        );
        Reetrance ethernautReetrance = Reetrance(levelAddress);
        /****************
         *    Attack     *
         *************** */
        ReetranceHack ReetranceHack = new ReetranceHack(levelAddress);

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
