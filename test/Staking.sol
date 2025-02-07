// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Staking.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract StakingTest is Test {
    Staking public staking;
    MockERC20 public token;
    address public alice = address(0x1);
    address public bob = address(0x2);
    uint256 public constant INITIAL_BALANCE = 1000 * 1e18;

    function setUp() public {
        staking = new Staking();
        token = new MockERC20("Test Token", "TEST");

        token.transfer(alice, INITIAL_BALANCE);
        token.transfer(bob, INITIAL_BALANCE);

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
    }

    function testStake() public {
        vm.startPrank(alice);
        token.approve(address(staking), INITIAL_BALANCE);
        staking.stake(address(token), 100 * 1e18);
        vm.stopPrank();

        (uint amount, , , , ) = staking.getStakeInfo(alice, address(token));
        assertEq(amount, 100 * 1e18, "Stake amount should be correct");
    }

    function testCalculateRewards() public {
        vm.startPrank(alice);
        token.approve(address(staking), INITIAL_BALANCE);
        staking.stake(address(token), 100 * 1e18);
        vm.stopPrank();

        // Fast forward 365 days
        vm.warp(block.timestamp + 365 days);

        uint256 rewards = staking.calculateRewards(alice, address(token));
        assertEq(rewards, 10 * 1e18, "Rewards should be 10% after one year");
    }

    function testStartUnstake() public {
        vm.startPrank(alice);
        token.approve(address(staking), INITIAL_BALANCE);
        staking.stake(address(token), 100 * 1e18);
        staking.startUnstake(address(token), 50 * 1e18);
        vm.stopPrank();

        (uint amount, , , uint unstakingAmount, uint unstakeStartTime) = staking
            .getStakeInfo(alice, address(token));
        assertEq(amount, 100 * 1e18, "Total stake should remain unchanged");
        assertEq(
            unstakingAmount,
            50 * 1e18,
            "Unstaking amount should be correct"
        );
        assertEq(
            unstakeStartTime,
            block.timestamp,
            "Unstake start time should be set"
        );
    }

    function testFinalizeUnstake() public {
        vm.startPrank(alice);
        token.approve(address(staking), INITIAL_BALANCE);
        staking.stake(address(token), 100 * 1e18);
        staking.startUnstake(address(token), 50 * 1e18);
        vm.stopPrank();

        // Fast forward 21 days
        vm.warp(block.timestamp + 21 days);

        vm.prank(alice);
        staking.finalizeUnstake(address(token));

        (uint amount, , , uint unstakingAmount, ) = staking.getStakeInfo(
            alice,
            address(token)
        );
        assertEq(amount, 50 * 1e18, "Remaining stake should be correct");
        assertEq(unstakingAmount, 0, "Unstaking amount should be reset");
        assertEq(
            token.balanceOf(alice),
            INITIAL_BALANCE - 50 * 1e18,
            "Token balance should be updated"
        );
    }

    function testCompleteUnstake() public {
        vm.startPrank(alice);
        token.approve(address(staking), INITIAL_BALANCE);
        staking.stake(address(token), 100 * 1e18);
        staking.startUnstake(address(token), 100 * 1e18);
        vm.stopPrank();

        // Fast forward 21 days
        vm.warp(block.timestamp + 21 days);

        vm.prank(alice);
        staking.finalizeUnstake(address(token));

        (uint amount, , , , ) = staking.getStakeInfo(alice, address(token));
        assertEq(amount, 0, "Stake should be completely removed");
    }
}
