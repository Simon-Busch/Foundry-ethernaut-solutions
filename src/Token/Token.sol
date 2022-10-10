// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {

    // Solidity ^0.8.0 prevents nativeyly over/underflows
    // thanks to unchecked we can force "wrong" behavior in this case
    unchecked {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }

    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
