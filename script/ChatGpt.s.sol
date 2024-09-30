// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ChatGpt} from "../src/ChatGpt.sol";

contract FeedbackSystemScript is Script {
    function setUp() public {}

    function run() public {
        string memory oracleAddressStr = vm.envString("ORACLE_ADDRESS");
        address oracleAddress = vm.parseAddress(oracleAddressStr);

        vm.startBroadcast();
        ChatGpt chatGpt = new ChatGpt(oracleAddress);
        console.log("ChatGpt deployed at:", address(chatGpt));
        vm.stopBroadcast();
    }
}
