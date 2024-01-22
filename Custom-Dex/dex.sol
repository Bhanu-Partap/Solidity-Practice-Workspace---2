// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./erc-20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Pair is ReentrancyGuard {
    mapping(bytes => Pool) pools;
    uint256 INITIAL_LP_TOKENS = 1000 * 10**18;

    struct Pool {
        mapping(address => uint256) tokenBalances;
        mapping(address => uint256) lpBalances;
        uint256 totalLpTokens;
    }

    modifier validTokenAddresses(
        address _token0Address,
        address _token1Address
    ) {
        require(_token0Address != _token1Address, "Address can't be different");
        require(
            _token0Address != address(0) && _token1Address != address(0),
            "Address must be valid"
        );
        _;
    }

    modifier hasBalanceAndAllowance(
        address _token0Address,
        address _token1Address,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) {
        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);

        require(
            token0Address.balanceOf(msg.sender) >= _token0Amount,
            "Insufficient Balance"
        );
        require(
            token1Address.balanceOf(msg.sender) >= _token1Amount,
            "Insufficient Balance"
        );
        require(
            token0Address.allowance(msg.sender, address(this)) == _token0Amount,
            "Insufficient allowance for token0"
        );
        require(
            token1Address.allowance(msg.sender, address(this)) == _token1Amount,
            "Insufficient allowance for token1"
        );

        _;
    }

    modifier poolMustExist(address _token0Address, address _token1Address) {
        Pool storage pool = getPool(_token0Address, _token1Address);
        require(pool.tokenBalances[_token0Address] != 0, " pool must exist");
        require(pool.tokenBalances[_token1Address] != 0, " pool must exist");

        _;
    }

    function getPool(address _token0Address, address _token1Address)
        internal
        view
        returns (Pool storage pool)
    {
        bytes memory key;
        if (_token0Address < _token1Address) {
            key = abi.encodePacked(_token0Address, _token1Address);
        } else {
            key = abi.encodePacked(_token1Address, _token0Address);
        }
        return Pool[key];
    }

    function transferToken(
        address _token0Address,
        address _token1Address,
        uint256 _token0Amount,
        uint256 _token1Amount
    ) public {
        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);

        require(
            token0Address.transferFrom(
                msg.sender,
                address(this),
                _token0Amount
            ),
            "Transfer of token0 Failed"
        );
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
        Pool storage pool = getPool(_token0Address, _token1Address);
        require(
            pool.tokenBalances[_token0Address] > 0 &&
                pool.tokenBalances[_token1Address] > 0,
            " Token value must be non - zero"
        );
        return(pool.tokenBalances[_token0Address]* 10**18/ pool.tokenBalances[_token1Address]);
    }

    function createPool(
        address _token0Address,
        address _token1Address,
        uint256 _token0Amount,
        uint256 _token1Amount
    )
        public
        validTokenAddresses(_token0Address, _token1Address)
        hasBalanceAndAllowance(
            _token0Address,
            _token1Address,
            _token0Amount,
            _token1Amount
        )
        nonReentrant
    {
        Pool storage pool = getPool(_token0Address, _token1Address);
        require(pool.tokenBalances[_token0Address] == 0, "Pool Already Exist");
        pool.tokenBalances[_token0Address] = _token0Amount;
        pool.tokenBalances[_token1Address] = _token1Amount;
        pool.lpBalances[msg.sender] = INITIAL_LP_TOKENS;
        pool.totalLpTokens = INITIAL_LP_TOKENS;


    }

    function addLiquidity(
        address _token0Address,
        address _token1Address,
        uint256 _token0Amount,
        uint256 _token1Amount
    )
        public
        validTokenAddresses(_token0Address, _token1Address)
        hasBalanceAndAllowance(
            _token0Address,
            _token1Address,
            _token0Amount,
            _token1Amount
        )
        poolMustExist(_token0Address, _token1Address)
        nonReentrant
        returns (uint256)
    {
        Pool storage pool = getPool(_token0Address, _token1Address);
        uint256 token0Price = getSpotPrice(_token0Address, _token1Address);
        require(token0Price * _token0Amount == _token1Amount * 10**18," must add liquidity at current spot price");
        transferToken(_token0Address, _token1Address, _token0Amount,_token1Amount);
        uint currentBalance = pool.tokenBalances[_token0Address];
        uint newTokens = (_token0Amount * INITIAL_LP_TOKENS) / currentBalance;

        pool.tokenBalances[_token0Address] += _token0Amount;
        pool.tokenBalances[_token1Address] += _token1Amount;
        pool.totalLpTokens += newTokens;
        pool.lpBalances[msg.sender] += newTokens;

    }

    function removeLiquidity(address _token0Address, address _token1Address)
     validTokenAddresses(_token0Address, _token1Address)
        poolMustExist(_token0Address, _token1Address)
        nonReentrant
        public
        returns (uint256)
    {
        Pool storage pool = getPool(_token0Address, _token1Address);
        uint balance = pool.lpBalances[msg.sender];
        require(balance > 0,"No liquidity was provided by the user");
        uint _token0Amount = (balance * pool.tokenBalances[_token0Address]) / pool.totalLpTokens;
        uint _token1Amount = (balance * pool.tokenBalances[_token1Address]) / pool.totalLpTokens;
        pool.lpBalances[msg.sender] = 0;
        pool.tokenBalances[_token0Address] -= _token0Amount;
        pool.tokenBalances[_token1Address] -= _token1Amount;
        pool.totalLpTokens -= balance;

        erc20 token0Address = erc20(_token0Address);
        erc20 token1Address = erc20(_token1Address);

        require(token0Address.transfer(msg.sender, _token0Amount), "Transfer  token0 failed !!");
        require(token1Address.transfer(msg.sender, _token1Amount), "Transfer  token1 failed !!");


    }

    function swap(
        address from,
        address to,
        uint256 amount
    ) public returns (uint256) {}
}
