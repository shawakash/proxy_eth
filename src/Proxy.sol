// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Proxy is Ownable {
    uint256 public num;
    address public implementation;

    event FallbackCall();
    event SetImplementationCall();

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function setImplementation(address _impl) public onlyOwner {
        implementation = _impl;
        emit SetImplementationCall();
    }

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);

        if (!success) {
            revert();
        }
        emit FallbackCall();
    }
}
