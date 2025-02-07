// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingProxy is Ownable {
    uint public constant INTEREST_RATE = 10; // 10% APR
    uint public constant UNSTAKE_DELAY = 21 days;

    struct Stake {
        uint amount;
        uint startTime;
        uint lastUpdate;
        uint unstakingAmount;
        uint unstakeStartTime;
    }

    //  userAddress => tokenAddress => Stake
    mapping(address => mapping(address => Stake)) public stakes;

    address public implementation;
    event FallbackCall();
    event SetImplementationCall();

    receive() external payable {}

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function setImplementation(address _impl) public onlyOwner {
        implementation = _impl;
        emit SetImplementationCall();
    }

    function getImplementation() public view returns (address) {
        return implementation;
    }

    fallback() external payable {
        (bool success, ) = implementation.delegatecall(msg.data);

        if (!success) {
            revert();
        }
        emit FallbackCall();
    }
}
