// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract user {
    address owner;

    constructor(address _owner) {
        owner = _owner;
    }

    //for receiving fund
    function deposit() external payable {}

    // for sending fund
    function withdraw(address payable _to, uint256 _amount) external {
        require(msg.sender == owner, "only owner");
        _to.transfer(_amount);
    }

    // for checking balance of smart contract wallet
    function getBalance() external view returns (uint256) {
        require(msg.sender == owner, "only owner");
        return address(this).balance;
    }

    // for delagate call to other contract
    function delegate(address _target, bytes memory _data)
        external
        returns (bytes memory)
    {
        (bool success, bytes memory result) = _target.delegatecall(_data);
        require(success, "Delegate call failed");
        return result;
    }

    //  for destructing the smartWalletcontract

    function destruct() external {

        require(msg.sender == owner, "only owner");
        selfdestruct(payable(msg.sender));
    }
}
