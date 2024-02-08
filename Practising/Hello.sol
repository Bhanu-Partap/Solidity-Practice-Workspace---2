// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract FixedSizeArray {
    // Declare a fixed size array of 5 integers
    uint[] public fixedArray;
    

    // Constructor
    // constructor() {
    //     // Initialize the array with some values
    //     fixedArray[0] = 1;
    //     fixedArray[1] = 2;
    //     fixedArray[2] = 3;
    //     fixedArray[3] = 4;
    //     fixedArray[4] = 5;
    // }

    // Function to push a value to the array
    function push() public {
        // This will fail because the array is already full
        for(uint256 i = 0; i<fixedArray.length;i++){
        fixedArray.push(i) ;

        }
    }
}