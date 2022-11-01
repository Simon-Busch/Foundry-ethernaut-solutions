// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
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
        ** First part
        * Decompose the byte code:
        * 0x => declare bytes code
        * 69 => PUSH 10
        * 602A => PUSH1  2A
        * 6000 => PUSH1  00
        * 52 => MSTORE take 1)offset and 2)value ( 32 bytes ) and store in memory
        *   Offset == 00
        *   Value == 2A ( what we need )
        * 6020 => PUSH1  20
        * 6000 => PUSH1  00
        * F3 => RETURN
        * This piece of bytes code returns :
        * 000000000000000000000000000000000000000000000000000000000000002a
        * Which is what is needed for the function whatIsTheMeaningOfLife and also equal to 42
        *-> This minimal smartcontract always and only returns 42
        *
        * Second part:
        *
        // * Then we prefix the first part with 69 - PUSH10 to place 10 bytes in stack
        * That will basically push the first part of the code
        * 6000 => PUSH1 00
        * 52 => MSTORE => store this in the memory
        *   Offset == 00
        *   Value == return of 69602A60005260206000F3 ( as prefixed with 69 ) return the 10 bytes
        * 600A => PUSH1 0A
        * 6016 => PUSH1 16
        * F3 return
       */
        address deployedContractAddress;
        // Deploy the raw bytecode via the `create` yul function
        // create(v, p, n)
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
