// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "hello-fs/Test.sol";
import {IERC20} from 'hello-oz/token/ERC20/IERC20.sol';
import {SafeERC20} from 'hello-oz/token/ERC20/utils/SafeERC20.sol';

import { UniversalRouter } from '../src/universal-router/index.sol';
import { PoolAddress } from '../src/v3-perpiphery/libraries/PoolAddress.sol';
import { IQuoterV2 } from '../src/v3-perpiphery/interfaces/IQuoterV2.sol';


interface IUniversalRouter {
    /// @notice Executes encoded commands along with provided inputs. Reverts if deadline has expired.
    /// @param commands A set of concatenated commands, each 1 byte in length
    /// @param inputs An array of byte strings containing abi encoded inputs for each command
    /// @param deadline The deadline by which the transaction must be executed
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}


contract UniversalRouterTest is Test {
    using UniversalRouter for UniversalRouter.ExecuteParam;
    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;

    address constant ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    address constant QUOTERV2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/arbitrum");
    }

    function test_swap() public {
        uint24 fee = 10000;
        (address alice, uint256 pk) = makeAddrAndKey("Alice");
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey({
            token0: GMX,
            token1: USDT,
            fee: fee
        });

        deal(USDT, alice, 100e6);
        UniversalRouter.ExecuteParam memory p = 
            UniversalRouter.param()
                .permit2Permit(
                    alice, 
                    USDT, 
                    100e6, 
                    uint48(block.timestamp + 1200), 
                    ROUTER,
                    block.timestamp + 1200, 
                    pk
                )
                .univ3SwapExactOut(
                    GMX,
                    fee,
                    USDT,
                    alice,
                    1e18,
                    60e18,
                    true
                );
        
        vm.startPrank(alice);
        IERC20(USDT).approve(PERMIT2, type(uint).max);
        IUniversalRouter(ROUTER).execute(p.commands, p.inputs, block.timestamp + 120);
        vm.stopPrank();
        uint spendUSDT = 100e6 - IERC20(USDT).balanceOf(alice);
        console2.log("[LOG] Alice buy 1 GMX using %s USDT", spendUSDT);
    }

    // function test_simpleSwap() public {
    //     uint24 fee = 10000;
    //     (address alice, uint256 pk) = makeAddrAndKey("Alice");

    //     deal(USDT, alice, 100e6);
    //     (uint256 amountInQuoted,,,) = IQuoterV2(QUOTERV2).quoteExactOutput(
    //         abi.encodePacked(GMX, fee, USDT), 
    //         1e18
    //     );
    //     console.log("Quoter result: amountIn = ", amountInQuoted);
    //     vm.startPrank(alice);
    //     UniversalRouter.simpleSwapTokensForExactTokens(
    //         pk, 
    //         USDT, 
    //         GMX, 
    //         fee, 
    //         1e18, 
    //         amountInQuoted * 1003 / 1000,
    //         block.timestamp + 12
    //     );
    //     vm.stopPrank();

    //     uint spendUSDT = 100e6 - IERC20(USDT).balanceOf(alice);
    //     console2.log("[LOG] Alice buy 1 GMX using %s USDT", spendUSDT);
    // }
    function test_simpleSwapTokensForExactTokens() public {
        (address alice, uint256 pk) = makeAddrAndKey("Alice");
        deal(USDT, alice, 2000e6);
        
        vm.startPrank(alice, alice);
        UniversalRouter.simpleSwapTokensForExactTokens(pk, USDT, GMX, 500, 20e18);
        vm.stopPrank();

        uint spendUSDT = 2000e6 - IERC20(USDT).balanceOf(alice);
        console2.log("[LOG] Alice buy 20 GMX using %s USDT", spendUSDT);
        console2.log("Remaining in router: ", IERC20(USDT).balanceOf(ROUTER));
        console2.log("Allowance for permit2: ", IERC20(USDT).allowance(alice, PERMIT2));
    }

    function test_simpleSwapEthForExactTokens() public {
        (address alice, uint256 pk) = makeAddrAndKey("Alice");
        deal(alice, 20 ether);
        vm.startPrank(alice, alice);
        UniversalRouter.simpleSwapEthForExactTokens(pk, GMX, 20e18);
        vm.stopPrank();

        uint spendETH = 20 ether - alice.balance;
        console2.log("[LOG] Alice buy 20 GMX using %s ETH", spendETH);
        console2.log("Remaining in router: ", ROUTER.balance);
        console2.log("Allowance for permit2: ", IERC20(WETH).allowance(alice, PERMIT2));
    }
}
