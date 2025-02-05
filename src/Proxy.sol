// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Proxy is Ownable {
    uint public num;
    address public implementation;
    event FallbackCall();
    event SetImplementationCall();

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function setNum(uint _num) public {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("setNum(uint256)", _num)
        );

        if (!success) {
            revert();
        }
    }

    function setImplementation(address _impl) public onlyOwner {
        implementation = _impl;
        emit SetImplementationCall();
    }

    fallback() external {
        emit FallbackCall();
    }
}
