pragma solidity ^0.4.13;

import './ERC20Mineable.sol';
import './Transmutable.sol';

/**
 * @title SmartMineral: A store of value on the Ethereum network
 * @dev User-centric mining component
 * @dev Transmutable interface for converting into different tokens
 */


contract SmartMineral is ERC20Mineable, Transmutable {

 string public constant name = "SmartMineral";
 string public constant symbol = "BTE";
 uint256 public constant decimals = 8;
 uint256 public constant INITIAL_SUPPLY = 0;

 // 21 Million coins at 8 decimal places
 uint256 public constant MAX_SUPPLY = 21000000 * (10**8);
 
 function SmartMineral() {

    totalSupply = INITIAL_SUPPLY;
    maximumSupply = MAX_SUPPLY;

    // 0.0001 Ether per block
    // Difficulty is so low because it doesn't include
    // gas prices for execution
    currentDifficultyWei = 100 szabo;
    minimumDifficultyThresholdWei = 100 szabo;
    
    // Ethereum blocks to internal blocks
    // Roughly 10 minute windows
    blockCreationRate = 50;

    // Adjust difficulty x claimed internal blocks
    difficultyAdjustmentPeriod = 2016;

    // Reward adjustment

    rewardAdjustmentPeriod = 210000;

    // This is the effective block counter, since block windows are discontinuous
    totalBlocksMined = 0;

    totalWeiExpected = difficultyAdjustmentPeriod * currentDifficultyWei;

    // Balance of this address can be used to determine total burned value
    // not including fees spent.
    burnAddress = 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;

    lastDifficultyAdjustmentEthereumBlock = block.number; 
 }


   /**
   * @dev SmartMineral can extend proof of burn into convertable units
   * that have token specific properties
   * @param to is the address of the contract that SmartMineral is converting into
   * @param value is the quantity of SmartMineral to attempt to convert
   */

  function transmute(address to, uint256 value) nonReentrant returns (bool, uint256) {
    require(value > 0);
    require(balances[msg.sender] >= value);
    require(totalSupply >= value);
    balances[msg.sender] = balances[msg.sender].sub(value);
    totalSupply = totalSupply.sub(value);
    TransmutableInterface target = TransmutableInterface(to);
    bool _result = false;
    uint256 _total = 0;
    (_result, _total) = target.transmuted(value);
    require (_result);
    Transmuted(msg.sender, this, to, value, _total);
    return (_result, _total);
  }

 }
