//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IJPYD is IERC20 {
  function mint (address _to, uint _amount) external;
}
