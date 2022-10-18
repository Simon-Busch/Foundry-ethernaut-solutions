// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "../src/Ethernaut.sol";

// forge test --match-contract DoubleEntryPointTest -vvvv
contract DoubleEntryPointTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        // create new instance of ethernaut
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our address 5 ether
    }

    function testDoubleEntryPointHack() public {
        /****************
         * Factory setup *
         *************** */
        DoubleEntryPointFactory doubleEntryPointFactory = new DoubleEntryPointFactory();
        ethernaut.registerLevel(doubleEntryPointFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(
            doubleEntryPointFactory
        );
        DoubleEntryPoint ethernautDoubleEntryPoint = DoubleEntryPoint(
            payable(levelAddress)
        );
        /****************
         *    Attack     *
         *************** */
        /*
         *The underlying token is an instance of the DET token implemented in the DoubleEntryPoint contract definition
         * and the CryptoVault holds 100 units of it. Additionally the CryptoVault also holds 100 of LegacyToken LGT.
         * Target : figure out where the bug is in CryptoVault and protect it from being drained out of tokens
         *
         * ** LegayToken ** ERC20 token contract
         * Interesting point that stands out here, the contract override the default transfer functrion adding its own logic
         *  will check if the delegate addres ( SLOT 0 ) is set to 0
         *   If that case simply calls transfer(to,value);
         *  If not, there is delegateTransfer to delegate contract
         *
         * It's important to understand that in our  case, delegate is DoubleEntryPoint contract
         *
         * There is also the function delegateToNewContract to to change the delegate but we need to be the owner.
         *
         *
         *
         * ** DoubleEntryPoint ** ERC20 token contract
         * In the constructor, all addresses are defined + minting 100LGT token to the cryptoVault.
         *
         * The onlyDelegateFrom modifier means that whichever function has this modifier,
         * that function can only be called by the LegacyToken and no one else.
         *
         * The modifier fortaNotify is the one used by the Forta bot.
         * It basically checks the old number of alerts with the new number of alert and see if an alert was raised.
         * If yes, transaction reverted.
         *
         * DelegateTransfer
         * Has onlyDelegateFrom modifier -> allowing only LegacyToken to call this function
         * Has fortaNotify modifier --> acts as bot detection and monitoring feature
         * Is calling _transfer (ERC20 function)
         *
         * ** CryptoVault **
         *
         * setUnderlying sets the address for the underlying token which is DoubleEntryPoint in this case
         *
         * sweepToken is not very secure, it basically checks if the ERC20token passed is != from underlying and sweep the whole balance
         * will send the funds to sweptTokensRecipient
         *
         * sweptTokensRecipient is initialized directly in the constructor.
         *
         * ** Forta **
         * function setDetectionBot is user to set new bot address
         * function notify is calling handleTransaction the bot address
         * -> This function is also called in fortaNotify modifier
         * function raiseAlert increment the alert
         *
         *
         *  Initially, the vault own 100 LGT && 100 DET.
         * here is the breakdown of the attack:
         * 1) CryptoVault.sweepToken(LGT)
         * 2) This triggers transfer from LegacyToken (sweptTokensRecipient, Vault's balance)
         * 3) A call happens in LegacyToken : delegate.delegateTransfer(to, value, msg.sender);
         * (sweptTokensRecipients, Vault balance, Vault address)
         *
         * The origSender is the same as Crypto vault, that's what we want to avoid.
         *
         *
         *
         *
         *
         *
         * Reminder, the goal here is protect it from being drained out of tokens :
         * In order to do so, we need to code a more secure bot.
         *
         * 1) get the address of the crypto vault
         * 2) Instanciate the new bot with the vault address
         * 3) Set the new detection bot
         */
        // -- 1  --
        CryptoVault vault = CryptoVault(
            ethernautDoubleEntryPoint.cryptoVault()
        );
        // -- 2 --
        UpdatedBot bot = new UpdatedBot(address(vault));
        // -- 3 --
        ethernautDoubleEntryPoint.forta().setDetectionBot(address(bot));

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
/*
* This idea of this contract is to detect potential abuse of CryptoVault
* 1) Need to extend from  IDetectionBot
* 2) actual address of the cryptoVault
* 3) we have seen that this function is needed in a bot.
*    Will raise an alert if certain conditions are met
* 4) The opcode calldataload(0xa8) extracts 32 bytes from the calldata starting from the 0xa8 byte.
* 5) additional check, if == ; raise alert.
*/
// -- 1 --
contract UpdatedBot is IDetectionBot {
    address private cryptoVault;

    // -- 2 --
    constructor(address _cryptoVault) public {
        cryptoVault = _cryptoVault;
    }

    // -- 3 --
    function handleTransaction(address user, bytes calldata msgData)
        external
        override
    {
        address origSender;
        assembly {
            origSender := calldataload(0xa8)
        // -- 4 --
        }
        // -- 5 --
        if (origSender == cryptoVault) {
            IForta(msg.sender).raiseAlert(user);
        }
    }
}
