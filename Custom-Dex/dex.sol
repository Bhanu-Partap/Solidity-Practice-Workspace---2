// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./erc-20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";


contract dex is ReentrancyGuard {
    // uint256 INITIAL_LP_TOKENS = 1000 * 10**18;
    // uint256 LP_FEE = 3 *100 /100;
    uint256 totalLpTokens;
    mapping(address => uint256) tokenBalances;
    mapping(address => uint256) lpBalances;

    // modifier validTokenAddresses(address _token0Address,address _token1Address ) {
    //     require(_token0Address != _token1Address, "Address can't be different");
    //     require(_token0Address != address(0) && _token1Address != address(0),
    //         "Address must be valid");
    //     _;
    // }

    // modifier hasBalanceAndAllowance( address _token0Address,address _token1Address,
    //     uint256 _token0Amount,
    //     uint256 _token1Amount
    // ) {
    //     erc20 token0Address = erc20(_token0Address);
    //     erc20 token1Address = erc20(_token1Address);

    //     require(token0Address.balanceOf(msg.sender) >= _token0Amount,
    //         "Insufficient Balance");
    //     require(token1Address.balanceOf(msg.sender) >= _token1Amount,
    //         "Insufficient Balance");
    //     require( token0Address.allowance(msg.sender, address(this)) == _token0Amount,
    //         "Insufficient allowance for token0" );
    //     require( token1Address.allowance(msg.sender, address(this)) == _token1Amount,
    //         "Insufficient allowance for token1" );
    //     _;
    // }

    // modifier poolMustExist(address _token0Address, address _token1Address) {
    //     Pool storage pool = getPool(_token0Address, _token1Address);
    //     require(pool.tokenBalances[_token0Address] != 0, " pool must exist");
    //     require(pool.tokenBalances[_token1Address] != 0, " pool must exist");
    //     _;
    // }

    // function getPool(address _token0Address, address _token1Address) internal view 
    // returns ()
    // {
    //     bytes32 key;
    //     if (_token0Address < _token1Address) {
    //         key = keccak256(abi.encodePacked(_token0Address, _token1Address));
    //     } else {
    //         key = keccak256(abi.encodePacked(_token1Address, _token0Address));
    //     }
    //     return pools[key];
    // }

    erc20 public token0Address;
    erc20 public token1Address;
    erc20 public lptokens;



    constructor(address _token1Address, address _token2Address) {
    token0Address = erc20(_token1Address);
    token1Address = erc20(_token2Address);
    lptokens = new erc20("Lp Token","LP",0);
}

    function transferToken(uint256 _token0Amount, uint256 _token1Amount) public {

        require( token0Address.transferFrom(msg.sender,address(this), _token0Amount),
            "Transfer of token0 Failed");
        require(token1Address.transferFrom(msg.sender,address(this),_token1Amount ),
            "Transfer of token1 Failed");
    }

    function getSpotPrice(address _token0Address, address _token1Address)
        public
        view
        returns (uint256)
    {
        require(
            tokenBalances[_token0Address] > 0 &&
            tokenBalances[_token1Address] > 0,
            " Token balance must be non - zero"
        );
        return(tokenBalances[_token0Address]* 10**18 / tokenBalances[_token1Address]);
    }

    function createPool(
        address _token0Address,
        address _token1Address,
        uint256 _token0Amount,
        uint256 _token1Amount
    )
        public
        // validTokenAddresses(_token0Address, _token1Address)
        // hasBalanceAndAllowance(
        //     _token0Address,
        //     _token1Address,
        //     _token0Amount,
        //     _token1Amount
        // )
        nonReentrant
        returns(string memory, uint)
    {
        require(tokenBalances[_token0Address] == 0 && tokenBalances[_token1Address] == 0, "Pool Already Exist");
        token0Address.approve(msg.sender, _token0Address, _token0Amount);
        token1Address.approve(msg.sender, _token1Address, _token1Amount);
        tokenBalances[_token0Address] = _token0Amount;
        tokenBalances[_token1Address] = _token1Amount;
        uint calculatedAmount=Math.sqrt(_token0Amount * _token1Amount);
        console.log(calculatedAmount);
        uint mintedLpTokens = lptokens.mint(msg.sender, calculatedAmount);
        console.log(mintedLpTokens);
        lpBalances[msg.sender] = mintedLpTokens ;
        totalLpTokens = lpBalances[msg.sender];
        console.log(totalLpTokens);
        return ("Lp token recieved : ",totalLpTokens);
    }


    function addLiquidity( address _token0Address, address _token1Address, uint256 _token0Amount,
        uint256 _token1Amount ) public
        // validTokenAddresses(_token0Address, _token1Address)
        // hasBalanceAndAllowance(
        //     _token0Address,
        //     _token1Address,
        //     _token0Amount,
        //     _token1Amount
        // )
        // // poolMustExist(_token0Address, _token1Address)
        nonReentrant returns (string memory, uint256)
    {
        uint256 token0Price = getSpotPrice(_token0Address, _token1Address);
        console.log(token0Price);
        token0Address.approve(msg.sender, address(this), _token0Amount);
        token1Address.approve(msg.sender, address(this), _token1Amount);
        // require(token0Price * _token0Amount == _token1Amount * 10**18," must add liquidity at current spot price");
//tranfering the tokens from user wallet to the contract
        transferToken(_token0Amount,_token1Amount);
        // uint currentBalance = tokenBalances[_token0Address];
        uint newTokens = Math.sqrt(_token0Amount * _token1Amount);
        console.log(newTokens);
        uint mintedLpTokens= lptokens.mint(msg.sender, newTokens);
        console.log(mintedLpTokens);
        tokenBalances[_token0Address] += _token0Amount;
        tokenBalances[_token1Address] += _token1Amount;
        totalLpTokens += mintedLpTokens;
        lpBalances[msg.sender] = mintedLpTokens;
        return("Lp token balance w.r.t added liquidity",lpBalances[msg.sender]);
    }

    function removeLiquidity(address _token0Address, address _token1Address)
    //  validTokenAddresses(_token0Address, _token1Address)
    //     poolMustExist(_token0Address, _token1Address)
        nonReentrant
        public
    {
        uint balance = lpBalances[msg.sender];
        require(balance > 0,"No liquidity was provided by the user");
        uint _token0Amount = (balance * tokenBalances[_token0Address]) / totalLpTokens;
        uint _token1Amount = (balance * tokenBalances[_token1Address]) / totalLpTokens;
        lpBalances[msg.sender] = 0;
        tokenBalances[_token0Address] -= _token0Amount;
        tokenBalances[_token1Address] -= _token1Amount;
        totalLpTokens -= balance;

        require(token0Address.transfer(msg.sender, _token0Amount), "Transfer  token0 failed !!");
        require(token1Address.transfer(msg.sender, _token1Amount), "Transfer  token1 failed !!");
    }

    function swap(
        address from,
        address to,
        uint256 _amount
    )
    // validTokenAddresses(from, to)
    //     poolMustExist(from, to)
        nonReentrant
         public returns (string memory) {
        // uint r = 10000 - LP_FEE;
        uint k = tokenBalances[from] * tokenBalances[to];
        uint amountIn = k * _amount / 10000;
        uint outputTokens = tokenBalances[to] * amountIn / tokenBalances[from] + amountIn;
        tokenBalances[from] += _amount;
        tokenBalances[to] -= outputTokens;
        require(token0Address.transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
        require(token1Address.transfer(msg.sender, outputTokens), "Transfer Failed");
        return("Swapping Completed");
    }
}
