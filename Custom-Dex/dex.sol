// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import  "./erc-20.sol";

contract Pair{

    mapping(bytes=> Pool) pools;

    struct Pool{
        mapping(address=>uint) tokenBalances;
        mapping(address=>uint256) lpBalances;
        uint totalLpTokens;
    }

    modifier validTokenAddresses(address _token0Address, address _token1Address){
        require(_token0Address != _token1Address, "Address can't be different");
        require(_token0Address != address(0) && _token1Address != address(0),"Address must be valid");
        _;
    }

    modifier hasBalanceAndAllowance(address _token0Address, address _token1Address, uint256 _amount0, uint256 _amount1){
        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);  

        require(token0Address.balanceOf(msg.sender)>= _amount0,"Insufficient Balance");
        require(token1Address.balanceOf(msg.sender)>= _amount1,"Insufficient Balance");
        require(token0Address.allowance(msg.sender,address(this))== _amount0,"Insufficient allowance for token0");
        require(token1Address.allowance(msg.sender,address(this))==_amount1,"Insufficient allowance for token1");

        _;
    }

    function getPool(address _token0Address, address _token1Address) internal view returns(Pool storage pool){
        bytes memory key;
        if(_token0Address< _token1Address){
            key = abi.encodePacked(_token0Address, _token1Address);
        }
        else{
            key = abi.encodePacked(_token1Address, _token0Address);
        }
        return Pool[key];
    }

    function transferToken(address _token0Address, address _token1Address, uint _token0Amount, uint _token1Amount) public {
        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);  

        require(token0Address.transferFrom(msg.sender, address(this), _token0Amount),"Transfer of token0 Failed");  
        require(token1Address.transferFrom(msg.sender, address(this), _token1Amount),"Transfer of token1 Failed");  

    }

    function createPair(address _token0Address, address _token1Address, uint256 _token0Amount, uint256 _token1Amount ) validTokenAddresses(_token0Address,  _token1Address)  public returns(uint256){
        Pool storage pool = getPool(_token0Address, _token1Address);
        require(pool.tokenBalances[_token0Address] ==0,"Pool Already Exist");
        pool.tokenBalances[_token0Address]=_token0Amount;
        pool.tokenBalances[_token1Address]=_token1Amount;
        

    }       


    function addLiquidity(address _token0Address, address token1Address, uint256 _token0Amount, uint256 _token1Amount )  public returns(uint256){

    }

    
    function removeLiquidity(address _token0Address, address token1Address)  public returns(uint256){

    }


    function swap(address from, address to , uint256 amount)  public returns(uint256){

    }

}