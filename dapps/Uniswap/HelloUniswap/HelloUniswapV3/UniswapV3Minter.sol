import {IUniswapV3MintCallback} from "../../src/v3/v3-core/interfaces/callback/IUniswapV3MintCallback.sol";

contract UniwapV3Minter is IUniswapV3MintCallback {
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external {
        
    }
}