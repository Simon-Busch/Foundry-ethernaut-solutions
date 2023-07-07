// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testGatekeeperOneHack() public {
        /****************
         * Factory setup *
         *************** */
        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(
            gatekeeperOneFactory
        );
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(
            payable(levelAddress)
        );
        vm.stopPrank();
        assertEq(ethernautGatekeeperOne.entrant(), address(0));
        /****************
         *    Attack     *
         *************** */

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
