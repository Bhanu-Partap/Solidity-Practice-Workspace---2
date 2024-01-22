// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import  "./erc-20.sol";

contract Pair{

    struct Pool{
        mapping(address=>uint) tokenBalances;
        mapping(address=>uint256) lpBalances;
    }

    function createPair(address _token0Address, address _token1Address, uint256 _token0Amount, uint256 _token1Amount )  public returns(uint256){
        require(_token0Address != _token1Address, "Address can't be different");
        require(_token0Address != address(0) && _token1Address != address(0),"Address must be valid");
        
    }


    function addLiquidity(address _token0Address, address token1Address, uint256 _token0Amount, uint256 _token1Amount )  public returns(uint256){

    }

    
    function removeLiquidity(address _token0Address, address token1Address)  public returns(uint256){

    }


    function swap(address from, address to , uint256 amount)  public returns(uint256){

    }

}