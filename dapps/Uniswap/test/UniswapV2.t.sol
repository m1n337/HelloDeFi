// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "hello-fs/Test.sol";

import {UniswapV2_Factory} from "evm-address/dapps/UniswapV2.sol";
import {USDT, USDC} from "evm-address/dapps/Tokens.sol";

import {IUniswapV2Factory} from "../src/v2-core/interfaces/IUniswapV2Factory.sol";

contract HelloUniswapV2 is Test {
    IUniswapV2Factory private factory;
    address private usdt;
    address private usdc;
    
    function setUp() public {
        factory = IUniswapV2Factory(UniswapV2_Factory.select());
        usdt = USDT.select();
        usdc = USDC.select();
    }

    function test_queryPair() public {
        address pair = factory.getPair(usdt, usdc);

        console2.log("factory = %s, usdt = %s, usdc = %s", address(factory), usdt, usdc);
        console2.log("USDT/USDC pari: ", pair);
    }
}