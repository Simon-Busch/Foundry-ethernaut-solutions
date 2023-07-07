// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PuzzleWallet/PuzzleWalletFactory.sol";
import "../src/Ethernaut.sol";

contract PuzzleWalletTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testPuzzleWalletHack() public {
        /****************
         * Factory setup *
         *************** */
        PuzzleWalletFactory puzzleWalletFactory = new PuzzleWalletFactory();
        (
            address levelAddressProxy,
            address levelAddressWallet
        ) = puzzleWalletFactory.createInstance{value: 1 ether}();
        PuzzleProxy ethernautPuzzleProxy = PuzzleProxy(
            payable(levelAddressProxy)
        );
        PuzzleWallet ethernautPuzzleWallet = PuzzleWallet(
            payable(levelAddressWallet)
        );
        vm.startPrank(player);
        /****************
         *    Attack     *
         *************** */


        /*****************
         *Level Submission*
         ***************  */
        assertEq(ethernautPuzzleProxy.admin(), player);
        assertEq(ethernautPuzzleWallet.owner(), player);
    }
}
