
  
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEventsPayment {
  function payment(address from, address to, address from_token, address to_token, uint from_amount, uint to_amount, uint fee, string memory ref, uint payback) external;

}
