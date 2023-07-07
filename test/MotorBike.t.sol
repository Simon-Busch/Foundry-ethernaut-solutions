// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract MotorbikeTest is Test {
    Ethernaut ethernaut;
    address payable player = payable(address(100));

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testMotorbikeHack() public {
        /****************
         * Factory setup *
         *************** */
        vm.startPrank(player);
        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        Engine ethernautEngine = Engine(payable(address(motorbike)));

        /****************
         *    Attack     *
         *************** */


        /*****************
         *Level Submission*
         ***************  */
        assertEq(engine.upgrader(), player);
    }
}
