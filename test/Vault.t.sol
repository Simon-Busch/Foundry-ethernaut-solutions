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
        vm.stopPrank();
        /****************
         *    Attack     *
         *************** */
        

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
