import {Test, console2} from "hello-fs/Test.sol";

import {WETH, USDT} from "evm-address/dapps/Tokens.sol";
import {UniswapV3_Factory as FACTORY} from "evm-address/dapps/UniswapV3.sol";

import {UniswapV3Plus} from "../../src/v3-plus/index.sol";

contract HelloUniswapV3 is Test {
    address weth;
    address usdt;
    address factory;
    
    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        weth = WETH.select();
        usdt = USDT.select();
        factory = FACTORY.select();
    }

    function test_hello_uniswapV3_get_best_pair() public {
        (address pair, uint24 fee) = UniswapV3Plus.getPair(weth, usdt);
        console2.log("pair = %s, fee = %s", pair, fee);
    }

    function test_hello_uniswapV3_pool_mint() public {
        (address pair, uint24 fee) = UniswapV3Plus.getPair(weth, usdt);
        // Task-1: mint with exact single amount0In / amount1In
        // TickLower, TickUpper, amount
        

        // Task-2: mint with exact amount0In / amount1In (auto fill another)

        // Task-3: mint with exact value liquidity

    }
}