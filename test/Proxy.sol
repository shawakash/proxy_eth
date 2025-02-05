// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {ImplementationV1} from "../src/ImplementationV1.sol";

contract ProxyTest is Test {
    Proxy public proxy;

    function setUp() public {
        address implementation = address(new ImplementationV1());

        proxy = new Proxy(implementation);
        proxy.setNum(42);
    }

    function testProxy() public {
        assertEq(proxy.num(), 42);
    }

    function testSetNum() public {
        proxy.setNum(43);
        assertEq(proxy.num(), 43);
    }

    function testSetImplementation() public {
        address newImplementation = address(new ImplementationV1());
        proxy.setImplementation(newImplementation);
        proxy.setNum(43);
        assertEq(proxy.num(), 43);
    }
}
