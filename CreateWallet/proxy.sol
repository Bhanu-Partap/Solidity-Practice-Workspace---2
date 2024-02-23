// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Proxy {
    
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external  {
        address _impl = implementation;
        assembly {
            // Copy call data to memory
            calldatacopy(0, 0, calldatasize())

            // Delegatecall to the implementation contract
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            // Copy the returned data to memory
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function set_implementation(address _implementation) public {
        implementation = _implementation;
    }
}

