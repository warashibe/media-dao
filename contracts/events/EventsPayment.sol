//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventsPayment is Ownable, AccessControlEnumerable {
  
  bytes32 public constant EMITTER_ROLE = keccak256("EMITTER_ROLE");

  event Payment(address indexed from, address indexed to, address indexed from_token, address to_token, uint from_amount, uint to_amount, uint fee, string ref, uint payback);

  modifier onlyEmitter() {
    require(hasRole(EMITTER_ROLE,msg.sender), "only EMITTER can execute");
    _;
  }
  
  constructor() {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(EMITTER_ROLE, _msgSender());
  }

  function payment(address from, address to, address from_token, address to_token, uint from_amount, uint to_amount, uint fee, string memory ref, uint payback) external onlyEmitter {
    emit Payment(from, to, from_token, to_token, from_amount, to_amount, fee, ref, payback);
  }
  
}
