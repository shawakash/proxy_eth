// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Proxy} from "../src/Proxy.sol";
import {ImplementationV1} from "../src/ImplementationV1.sol";

contract CounterScript is Script {
    Proxy public proxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address implementation = address(new ImplementationV1());
        proxy = new Proxy(implementation);

        vm.stopBroadcast();
    }
}
