// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract Privacy {

  bool public locked = true; // SLOT 0
  uint256 public ID = block.timestamp; // SLOT 1
  uint8 private flattening = 10; // SLOT 2
  uint8 private denomination = 255; // SLOT 2
  uint16 private awkwardness = uint16(block.timestamp); // SLOT 2 //!! now is deprecated we need to use block.timestamp.
  bytes32[3] private data; // SLOT 3
  // bytes32[0] -- SLOT3
  // bytes32[1] -- SLOT4
  // bytes32[2] -- SLOT5 => That's what we want
  //!! reminder: 1SLOT = 32 bytes
  constructor(bytes32[3] memory _data) public {
    data = _data;
  }

  function unlock(bytes16 _key) public {
    require(_key == bytes16(data[2]));
    locked = false;
  }

  /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}
