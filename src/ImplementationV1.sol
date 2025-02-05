// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ImplementationV1 {
    address private owner;
    uint256 public num;

    function setNum(uint256 _num) public {
        num = _num;
    }
}
