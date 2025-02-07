// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {
    address private owner;
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

    event Staked(address indexed user, address indexed token, uint256 amount);
    event UnstakeStarted(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event Unstaked(address indexed user, address indexed token, uint256 amount);

    constructor() {}

    function stake(address _token, uint _amount) external nonReentrant {
        // Stake Amount check
        require(_amount > 0, "Stake amount must be > 0");
        // Transfer the token to this contract
        require(
            IERC20(_token).transferFrom(msg.sender, address(this), _amount),
            "Token Transfer failed"
        );

        // Update the stake
        Stake storage userStake = stakes[msg.sender][_token];

        // If that token is already staked by the user
        if (userStake.amount > 0) {
            userStake.amount += calculateRewards(msg.sender, _token);
        } else {
            userStake.startTime = block.timestamp;
        }
        userStake.amount += _amount;
        userStake.lastUpdate = block.timestamp;

        emit Staked(msg.sender, _token, _amount);
    }

    function calculateRewards(
        address _user,
        address _token
    ) public view returns (uint256) {
        Stake memory userStake = stakes[_user][_token];
        uint256 duration = block.timestamp - userStake.lastUpdate;
        return (userStake.amount * INTEREST_RATE * duration) / (365 days * 100);
    }

    function startUnstake(address _token, uint _amount) external {
        Stake storage userStake = stakes[msg.sender][_token];
        require(userStake.amount > 0, "No active stake");
        require(
            _amount > 0 && _amount <= userStake.amount,
            "Invalid unstake amount"
        );
        require(
            userStake.unstakingAmount == 0,
            "Unstaking already in progress"
        );

        userStake.amount += calculateRewards(msg.sender, _token);
        require(
            _amount <= userStake.amount,
            "Insufficient balance including rewards"
        );

        userStake.unstakingAmount = _amount;
        userStake.unstakeStartTime = block.timestamp;
        userStake.lastUpdate = block.timestamp;

        emit UnstakeStarted(msg.sender, _token, _amount);
    }

    function finalizeUnstake(address token) external nonReentrant {
        Stake storage userStake = stakes[msg.sender][token];
        require(userStake.unstakingAmount > 0, "No unstaking in progress");
        require(
            block.timestamp >= userStake.unstakeStartTime + UNSTAKE_DELAY,
            "21-day lock active"
        );

        uint256 amountToUnstake = userStake.unstakingAmount;
        userStake.amount -= amountToUnstake;
        userStake.unstakingAmount = 0;
        userStake.unstakeStartTime = 0;

        require(
            IERC20(token).transfer(msg.sender, amountToUnstake),
            "Transfer failed"
        );

        emit Unstaked(msg.sender, token, amountToUnstake);

        if (userStake.amount == 0) {
            delete stakes[msg.sender][token];
        }
    }

    function getStakeInfo(
        address user,
        address token
    ) external view returns (uint256, uint256, uint256, uint256, uint256) {
        Stake memory stake = stakes[user][token];
        return (
            stake.amount,
            stake.startTime,
            stake.lastUpdate,
            stake.unstakingAmount,
            stake.unstakeStartTime
        );
    }
}
