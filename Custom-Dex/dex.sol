// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./erc-20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Pair is ReentrancyGuard {
    uint256 INITIAL_LP_TOKENS = 1000 * 10**18;
    uint256 LP_FEE = 3 *100 /100;
    // uint256 tokenBalances;
    // uint256 lpBalances;
    uint256 totalLpTokens;
    mapping(address => uint256) tokenBalances;
    mapping(address => uint256) lpBalances;


    // mapping(bytes32 => Pool) pools;
    
    // struct Pool {
    //     Pool2 [] lpdetails;
    // }

    // struct Pool2{
    //     uint256 totalLpTokens;
    // }



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

    function transferToken( address _token0Address,address _token1Address,uint256 _token0Amount,
        uint256 _token1Amount) public {

        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);

        require( token0Address.transferFrom( msg.sender,address(this), _token0Amount),
            "Transfer of token0 Failed" );
        require(
            token1Address.transferFrom(
                msg.sender,
                address(this),
                _token1Amount
            ),
            "Transfer of token1 Failed"
        );
    }

    function getSpotPrice(address _token0Address, address _token1Address)
        public
        view
        returns (uint256)
    {
        // Pool storage pool = getPool(_token0Address, _token1Address);
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
        // nonReentrant
    {
        // Pool storage pool = getPool(_token0Address, _token1Address);
        // require(tokenBalances[_token0Address] == 0, "Pool Already Exist");
        tokenBalances[_token0Address] = _token0Amount;
        tokenBalances[_token1Address] = _token1Amount;
        lpBalances[msg.sender] = INITIAL_LP_TOKENS;
        totalLpTokens = INITIAL_LP_TOKENS;
    }


    function addLiquidity(
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
        // // poolMustExist(_token0Address, _token1Address)
        // nonReentrant
        returns (string memory, uint256)
    {
        uint256 token0Price = getSpotPrice(_token0Address, _token1Address);
        require(token0Price * _token0Amount == _token1Amount * 10**18," must add liquidity at current spot price");
        transferToken(_token0Address, _token1Address, _token0Amount,_token1Amount);
        uint currentBalance = tokenBalances[_token0Address];
        uint newTokens = (_token0Amount * INITIAL_LP_TOKENS) / currentBalance;
        tokenBalances[_token0Address] += _token0Amount;
        tokenBalances[_token1Address] += _token1Amount;
        totalLpTokens += newTokens;
        lpBalances[msg.sender] += newTokens;
        return("Lp token balance w.r.t added liquidity",lpBalances[msg.sender]);
    }

    function removeLiquidity(address _token0Address, address _token1Address)
    //  validTokenAddresses(_token0Address, _token1Address)
    //     poolMustExist(_token0Address, _token1Address)
    //     nonReentrant
        public
        returns (uint256)
    {
        // Pool storage pool = getPool(_token0Address, _token1Address);
        uint balance = lpBalances[msg.sender];
        require(balance > 0,"No liquidity was provided by the user");
        uint _token0Amount = (balance * tokenBalances[_token0Address]) / totalLpTokens;
        uint _token1Amount = (balance * tokenBalances[_token1Address]) / totalLpTokens;
        lpBalances[msg.sender] = 0;
        tokenBalances[_token0Address] -= _token0Amount;
        tokenBalances[_token1Address] -= _token1Amount;
        totalLpTokens -= balance;

        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);

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
         public returns (uint256) {
        // Pool storage pool = getPool(from, to);
        // uint r = 10000 - LP_FEE;
        uint amountIn = r * _amount / 10000;
        uint outputTokens = tokenBalances[to] * amountIn / tokenBalances[from] + amountIn;
        tokenBalances[from] += _amount;
        tokenBalances[to] -= outputTokens;

        erc20 contractFrom = erc20(from);
        erc20 contractTo = erc20(to);

        require(contractFrom.transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
        require(contractTo.transfer(msg.sender, outputTokens), "Transfer Failed");
    }
}
