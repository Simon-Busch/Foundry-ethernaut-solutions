// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import './Reentrance.sol';

contract ReentranceHack {
    Reentrance public challenge;
    uint256 initialDeposit;

    constructor(address challengeAddress) {
        challenge = Reentrance(challengeAddress);
    }

    function attack() external payable {

    }
}
