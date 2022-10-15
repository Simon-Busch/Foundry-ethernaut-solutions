// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract MagicNumTest -vvvv
contract MagicNumTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testMagicNumHack() public {
        /****************
         * Factory setup *
         *************** */
        MagicNumFactory magicNumFactory = new MagicNumFactory();
        ethernaut.registerLevel(magicNumFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(magicNumFactory);
        MagicNum ethernautMagicNum = MagicNum(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        /*
         * In order to solve this level, based on hint, we need to dive in opcode
         * we need to combine 2 things Init code and runtime code
         * Knowing that the max must be under 10 opcodes.
         *  600a -- push 10  => will set the runtime code size --> 1
         *  600c -- push 12  => is the runtime code start byte --> 2
         *  6000 -- push 0  => is the memory address to copy to --> 3
         *  39   -- codecopy
         *  600a -- push amount of bytes to return --> 4
         *  6000 -- memory address to start returning from --> 5
         *  f3   -- return
         *  RUNTIME CODE
         *  602a -- push value to return (42 in decimal) --> 6
         *  6080 -- push mem address to store --> 7
         *  52   -- mstore
         *  6020 -- push number of bytes to return --> 8
         *  6080 -- push mem address to return --> 9
         *  f3   -- return --> 10 - final
         */

        // bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        // address addr;
        // assembly {
        //   addr := create(0, add(code, 0x20), mload(code))
        //   if iszero(extcodesize(addr)) {
        //     revert(0, 0)
        //   }
        // }
        // ethernautMagicNum.setSolver(addr);
        /*
        * The goal here is to deploy a contract that only return 42
        * and is MAX 10 opcodes
        */
        address deployedContractAddress;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0x68, 0x69602A60005260206000F3600052600A6016F3))
            deployedContractAddress := create(0, ptr, 0x13)
        }
        ethernautMagicNum.setSolver(deployedContractAddress);
        assertEq(
            Solver(deployedContractAddress).whatIsTheMeaningOfLife(),
            0x000000000000000000000000000000000000000000000000000000000000002a
            // = 42 we know that from the factory
        );

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
