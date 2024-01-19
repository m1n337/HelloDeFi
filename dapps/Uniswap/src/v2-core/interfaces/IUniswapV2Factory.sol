interface IUniswapV2Factory {
    function feeTo() external view returns(address);
    function feeToSetter() external view returns(address);

    function getPair(
        address token0,
        address token1
    ) external view returns(address pair);
    
    function allPairs(uint256 index) external view returns(address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns(address pair);
}