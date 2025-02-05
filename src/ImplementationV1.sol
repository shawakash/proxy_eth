// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ImplementationV1 {
    address private owner;
    uint public num;

    function setNum(uint _num) public {
        num = _num;
    }
}
