// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IOracle {
    function createLlmCall(uint promptId) external returns (uint);
}
