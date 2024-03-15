// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// directory of VDOIT token
import "./IcoToken.sol";

contract ICO {
    mapping(address => uint256) public sales;

    address public admin;
    uint256 month;
    uint256 public start;
    uint256 public end;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public Hardcap;
    uint256 public coin_price;
    uint256 public availableTokens;
    uint256 public usdtTotaltoken;

    Token public token;
    IERC20 public usdt;

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    modifier icoActive() {
        require(
            block.timestamp > start &&
                block.timestamp < end &&
                availableTokens > 0,
            "ICO must be active"
        );
        _;
    }

    modifier icoEnded() {
        require(
            block.timestamp >= end || availableTokens == 0,
            "ICO must have ended"
        );
        _;
    }

    constructor(
        address usdtAddress,
        address tokenAddress,
        uint256 _start,
        uint256 _end,
        uint256 _coinprice,
        uint256 hardcap,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) {
        token = Token(tokenAddress);
        usdt = IERC20(usdtAddress);

        require(_minPurchase > 0, "_minPurchase should > 0");
        require(
            maxPurchase > 0 && maxPurchase <= availableTokens,
            "_maxPurchase should be > 0 and <= _availableTokens"
        );

        admin = msg.sender;
        start = _start;
        end = _end;
        coin_price = _coinprice;
        Hardcap = hardcap;
        minPurchase = _minPurchase;
        maxPurchase = _maxPurchase;
    }

    function buy(uint256 usdtAmount) external icoActive {
        require(
            usdtAmount >= minPurchase && usdtAmount <= maxPurchase,
            "have to buy between minPurchase and maxPurchase"
        );
        uint256 tokenAmount = usdtAmount / coin_price;
        require(
            tokenAmount <= availableTokens,
            "Not enough tokens left for sale"
        );

        usdt.transferFrom(msg.sender, address(this), usdtAmount);
        usdtTotaltoken = usdtTotaltoken + usdtAmount;
        // token.transfer(msg.sender, tokenAmount);
        sales[msg.sender] = tokenAmount;
        availableTokens = Hardcap - tokenAmount;
    }

    function ChangerateVDOITtoUSDT(uint256 rate) external onlyAdmin {
        coin_price = rate;
    }

    function claimusdtPermonth() external onlyAdmin {
        month++;
        require(
            block.timestamp > start && block.timestamp > ( 60 * 24 * 30),
            "eligible"
        );
        uint256 amount = usdtTotaltoken / 10;
        usdt.transfer(admin, amount);
        usdtTotaltoken = usdtTotaltoken - amount;
    }

    function collectUsdt() external onlyAdmin icoEnded {
        usdt.transfer(admin, usdtTotaltoken);
    }
}