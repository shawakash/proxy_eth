// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {ImplementationV1} from "../src/ImplementationV1.sol";
import {ImplementationV2} from "../src/ImplementationV2.sol";

contract ProxyTest is Test {
    Proxy public proxy;

    function setUp() public {
        address implementation = address(new ImplementationV1());

        proxy = new Proxy(implementation);
    }

    function testProxy() public {
        assertEq(proxy.num(), 0);
    }

    function testSetNum() public {
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("setNum(uint256)", 43)
        );

        if (!success) {
            revert();
        }

        assertEq(proxy.num(), 43);
    }

    function testPutNumOnImplementationV1() public {
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("putNum(uint256)", 43)
        );

        assertEq(success, false);
    }

    function testPutNumOnImplementationV2() public {
        address newImplementation = address(new ImplementationV2());
        proxy.setImplementation(newImplementation);

        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("putNum(uint256)", 21)
        );

        if (!success) {
            revert();
        }

        assertEq(proxy.num(), 21 * 2);
    }
}
