interface IOracle {
    function createLlmCall(uint promptId) external returns (uint);
}
