// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ImplementationV2 {
    address private owner;
    uint public num;

    function setNum(uint _num) public {
        num = _num;
    }

    function putNum(uint _num) public {
        num = 2 * _num;
    }
}
