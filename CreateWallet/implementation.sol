// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./user.sol";

contract implementation {
    mapping(address=>address) usertowalletaddress;
    
    //event emit when smartContractWallet is created for user
    event smartwalletCreated(address user, address smartWalletaddress);

    //creating a smart wallet contract for user
    function createWalletforUser(address _user) external {
        user smartWalletcontractAddress = new user(_user);
        usertowalletaddress[_user]=address(smartWalletcontractAddress);
        emit smartwalletCreated(_user, address(smartWalletcontractAddress));
    }
// get smartContractwallet of user
  function getUserwallet(address _user) external view  returns(address){
    return usertowalletaddress[_user];
  }
}
