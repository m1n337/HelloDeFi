import {Test, console2} from "hello-fs/Test.sol";
import {Vm} from "hello-fs/Vm.sol";

import {IERC20} from 'hello-oz/token/ERC20/IERC20.sol';
import {SafeERC20} from 'hello-oz/token/ERC20/utils/SafeERC20.sol';

import { Constants } from "../universal-router/libraries/Constants.sol";
import { Commands } from "..//universal-router/libraries/Commands.sol";
import { IQuoterV2 } from '../v3/interfaces/IQuoterV2.sol';

import {IUniversalRouter} from "../universal-router/interfaces/IUniversalRouter.sol";

import { IAllowanceTransfer, IEIP712 } from "../permit2/interfaces/IAllowanceTransfer.sol";
import { PermitSignature } from "../permit2/utils/PermitSignature.sol";

import { UniswapV3Plus, PoolAddress } from "../v3-plus/index.sol";

library UniversalRouter {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    using UniversalRouter for ExecuteParam;
    using SafeERC20 for IERC20;

    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    
    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant UNIVERSAL_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

    struct ExecuteParam {
        bytes commands;
        bytes[] inputs;
    }

    function addCommand(ExecuteParam storage param, bytes1 cmd) private {
        param.commands = abi.encodePacked(param.commands, cmd);
    }

    function addInput(ExecuteParam storage param, bytes memory input) private {
        param.inputs.push(input);
    }

    function param() internal returns(ExecuteParam storage param) {
        assembly {
            // keccak("UniversalRouter.ExecuteParam")
            param.slot := 0xa6a397552d7be5f2974a5ce28e661aff59694025c7d106d93d6190afdf893b7d
        }
    }

    function _checkPermit2Allowance(address token, address from, uint256 amount) private {
        if (IERC20(token).allowance(from, PERMIT2) != type(uint).max) {
            IERC20(token).approve(PERMIT2, type(uint).max);
        }
    }

    function quoteExactOutput(address tokenIn, address tokenOut, uint24 fee, uint256 amount) private returns(uint256) {

        (uint256 amountInQuoted,,,) = IQuoterV2(QUOTERV2).quoteExactOutput(
            abi.encodePacked(tokenOut, fee, tokenIn), 
            amount
        );

        return amountInQuoted;
    }

    address constant QUOTERV2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;
    function simpleSwapEthForExactTokens(
        uint256 privateKey,
        address tokenOut,
        uint256 amountOut
    ) internal {
        (,uint24 fee) = UniswapV3Plus.getPair(WETH, tokenOut);

        uint256 amountInQuoted = quoteExactOutput(WETH, tokenOut, fee, amountOut);
        // Default slipplege: 0.5%
        uint256 amountInMax = amountInQuoted * 1005 / 1000;
        swapEthForExactTokens(
            privateKey, 
            tokenOut, 
            fee, 
            amountOut, 
            amountInMax, 
            block.timestamp + 120
        );
    }

    function simpleSwapTokensForExactTokens(
        uint256 privateKey,
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) internal {
        (,uint24 fee) = UniswapV3Plus.getPair(tokenIn, tokenOut);
        simpleSwapTokensForExactTokens(privateKey, tokenIn, tokenOut, fee, amountOut);
    }

    function simpleSwapTokensForExactTokens(
        uint256 privateKey,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut
    ) internal {
        
        uint256 amountInQuoted = quoteExactOutput(tokenIn, tokenOut, fee, amountOut);
        // Default slipplege: 0.5%
        uint256 amountInMax = amountInQuoted * 1005 / 1000;
        swapTokensForExactTokens(
            privateKey, 
            tokenIn, 
            tokenOut, 
            fee, 
            amountOut, 
            amountInMax, 
            block.timestamp + 120
        );
    }

    function swapEthForExactTokens(
        uint256 privateKey,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint256 amountInMax,
        uint256 deadline
    ) internal {
        address from = vm.addr(privateKey);
        _checkPermit2Allowance(WETH, from, amountInMax);

        param()
            .wrapEth(from, amountInMax)
            .permit2Permit(
                from,
                WETH,
                uint160(amountInMax),
                uint48(deadline),
                UNIVERSAL_ROUTER,
                deadline,
                privateKey
            )
            .univ3SwapExactOut(
                WETH,
                fee,
                tokenOut,
                from,
                amountOut,
                amountInMax,
                true
            )
            .sweepEth(from)
            .execute(
                amountInMax,
                deadline
            );
        // Need to sweep extra Eth paid?
    }

    function swapTokensForExactTokens(
        uint256 privateKey,
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint256 amountInMax,
        uint256 deadline
    ) internal {
        address from = vm.addr(privateKey);
        _checkPermit2Allowance(tokenIn, from, amountInMax);

        param()
            .permit2Permit(
                from,
                tokenIn,
                uint160(amountInMax),
                uint48(deadline),
                UNIVERSAL_ROUTER,
                deadline,
                privateKey
            )
            .univ3SwapExactOut(
                tokenIn,
                fee,
                tokenOut,
                from,
                amountOut,
                amountInMax,
                true
            ).execute(
                0,
                deadline
            );
    }

    function execute(
        ExecuteParam storage param,
        uint256 value,
        uint256 deadline
    ) internal {
        IUniversalRouter(UNIVERSAL_ROUTER).execute{value: value}(param.commands, param.inputs, deadline);
    }

    function wrapEth(
        ExecuteParam storage param,
        address recipient,
        uint256 amount
    ) internal returns (ExecuteParam storage) {
        bytes memory input = abi.encode(recipient, amount);

        return newParams(param, Commands.WRAP_ETH, input);
    }

    function sweep(
        ExecuteParam storage param,
        address token,
        address recipient,
        uint256 amountMin
    ) internal returns(ExecuteParam storage) {
        bytes memory input = abi.encode(token, recipient, amountMin);

        return newParams(param, Commands.SWEEP, input);
    }

    function sweepEth(
        ExecuteParam storage param,
        address recipient
    ) internal returns(ExecuteParam storage) {
        bytes memory input = abi.encode(Constants.ETH, recipient, UNIVERSAL_ROUTER.balance);

        return newParams(param, Commands.SWEEP, input);
    }

    function permit2Permit(
        ExecuteParam storage param,
        address from,
        address token,
        uint160 amount,
        uint48 expiration,
        address spender,
        uint256 sigDeadline,
        uint256 privateKey
    ) internal returns (ExecuteParam storage) {
        (,,uint48 nonce) = IAllowanceTransfer(PERMIT2).allowance(from, token, spender);

        IAllowanceTransfer.PermitSingle memory permit = IAllowanceTransfer.PermitSingle({
            details: IAllowanceTransfer.PermitDetails({
                token: token,
                amount: amount,
                expiration: expiration,
                nonce: nonce
            }),
            spender: spender,
            sigDeadline: sigDeadline
        });

        bytes memory sig = PermitSignature.getPermitSignature(permit, privateKey, IEIP712(PERMIT2).DOMAIN_SEPARATOR());
    
        bytes memory input = abi.encode(permit, sig);

        return newParams(param, Commands.PERMIT2_PERMIT, input);
    }

    function univ3SwapExactOut(
        ExecuteParam storage param,
        address tokenIn,
        uint24 fee,
        address tokenOut,
        address recipient, 
        uint256 amountOut,
        uint256 amountInMax,
        bool payerIsUser
    ) internal returns(ExecuteParam storage) {
        if (tokenIn > tokenOut) (tokenIn, tokenOut) = (tokenOut, tokenIn);
        bytes memory path = abi.encodePacked(tokenOut, fee, tokenIn);
        bytes memory input = abi.encode(recipient, amountOut, amountInMax, path, payerIsUser);
        
        return newParams(param, Commands.V3_SWAP_EXACT_OUT, input);
    }

    function newParams(ExecuteParam storage param, uint256 cmd, bytes memory input) internal returns(ExecuteParam storage) {
        addCommand(param, bytes1(uint8(cmd)));
        addInput(param, input);
        
        return param;
    }
}

import {Script, console2} from "hello-fs/Script.sol";

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