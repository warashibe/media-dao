//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStorage  {
  function getUint(bytes32 _key) external view returns(uint);

  function getAddress(bytes32 _key) external view returns(address);

  function setUint(bytes32 _key, uint _value) external;

  function setAddress(bytes32 _key, address _value) external;
    
}
