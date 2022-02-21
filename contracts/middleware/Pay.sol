//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IJPYD} from "../interfaces/IJPYD.sol";
import {EIP712MetaTransaction} from "../lib/EIP712MetaTransaction.sol";
import {IStorage} from "../interfaces/IStorage.sol";
import {IEventsPayment} from "../interfaces/IEventsPayment.sol";
import "hardhat/console.sol";

contract Pay is Ownable, EIP712MetaTransaction("Pay", "1")  {
  address public payback_token;
  address public treasury;
  address public store;
  address public events;
  
  uint public minAmount = 10 ** 18;
  uint public minPayback = 10 ** 18;
  uint public minFee = 10 ** 18;
  uint public fee;
  uint public rate = 10 * 10 ** 18;
  
  constructor(uint _fee, address _payback_token, address _treasury, address _store, address _events) {
    require(_fee <= 10000, "fee must be less than or equal to 10000");
    fee = _fee;
    payback_token = _payback_token;
    treasury = _treasury;
    store = _store;
    events = _events;
  }
  
  function _payback (uint amount) internal {
    IJPYD(payback_token).mint(msgSender(), amount);
  }
  
  function _calcFees(uint amount, uint payback) internal view returns(uint tx_fee, uint payback_amount){
    payback_amount = amount * payback / 10000;
    if(payback_amount < minPayback) payback_amount = minPayback;
    uint base_tx_fee = amount * fee / 10000;
    if(base_tx_fee < minFee) base_tx_fee = minFee;
    tx_fee = base_tx_fee > payback_amount ? base_tx_fee : payback_amount;
    if(tx_fee > amount) tx_fee = amount;
  }
  
  function toJPYD(uint amount) public view returns (uint){
    return amount * rate / 10 ** 18;
  }
  
  function pay(address to, string memory ref, uint payback) public payable {
    require(msgSender() != to, "you cannot pay yourself");
    require(payback <= 10000, "payback must be equal to or less than 10000");
    uint amount = msg.value;
    uint jpyd = toJPYD(amount);
    require(minAmount < jpyd, "amount too small");
    (, uint payback_amount) = _calcFees(jpyd, payback);
    (uint tx_fee_astr,) = _calcFees(amount, payback);
    payable(to).transfer(amount - tx_fee_astr);
    payable(treasury).transfer(tx_fee_astr);
    IEventsPayment(events).payment(msgSender(), to, address(0), address(0), amount, amount, tx_fee_astr, ref, payback_amount);
    _recordVPs(msgSender(), to, payback_amount);
    _payback(payback_amount);
  }
  
  function setMinAmount(uint _int) public onlyOwner {
    minAmount = _int;
  }
  
  function setMinFee(uint _int) public onlyOwner {
    minFee = _int;
  }
  
  function setMinPayback(uint _int) public onlyOwner {
    minPayback = _int;
  }

  function setFee(uint _int) public onlyOwner {
    fee = _int;
  }
  
  function setRate(uint _int) public onlyOwner {
    rate = _int;
  }

  function _setUint(bytes memory _key, uint _uint) internal {
    return IStorage(store).setUint(keccak256(_key), _uint);
  }

  function _getUint(bytes memory _key) internal view returns(uint){
    return IStorage(store).getUint(keccak256(_key));
  }
  
  function _recordVPs(address from, address to, uint amount) internal {
    bytes memory key_ivp = abi.encode("ivp", from);
    bytes memory key_pvp = abi.encode("pvp", to);
    bytes memory key_total_mined = abi.encode("total_mined");
    _setUint(key_ivp, _getUint(key_ivp) + amount);
    _setUint(key_pvp, _getUint(key_pvp) + amount);
    _setUint(key_total_mined, _getUint(key_total_mined) + amount);
  }

  function getTotalMined() public view returns (uint) {
    return _getUint(abi.encode("total_mined"));
  }
  
  function getIVP(address _addr) public view returns (uint) {
    return _getUint(abi.encode("ivp", _addr));
  }
  
  function getPVP(address _addr) public view returns (uint) {
    return _getUint(abi.encode("pvp", _addr));
  }
  
  function getAllStats(address _addr) public view returns (uint ivp, uint pvp, uint total_mined, uint astar_rate) {
    return (getIVP(_addr), getPVP(_addr), getTotalMined(), rate);
  }

}
