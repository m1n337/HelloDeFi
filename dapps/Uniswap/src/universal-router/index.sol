
// @Target contract: Uniswap Universal Router 
// @Support version: v1_2

import {Vm} from "hello-fs/Vm.sol";
import {IERC20} from 'hello-oz/token/ERC20/IERC20.sol';
import {SafeERC20} from 'hello-oz/token/ERC20/utils/SafeERC20.sol';

import { Constants } from "./libraries/Constants.sol";
import { Commands } from "./libraries/Commands.sol";
import { PermitSignature } from "../permit2/utils/PermitSignature.sol";
import { IAllowanceTransfer, IEIP712 } from "../permit2/interfaces/IAllowanceTransfer.sol";
import { IQuoterV2 } from '../v3-perpiphery/interfaces/IQuoterV2.sol';

import { UniswapV3 } from "../v3-perpiphery/index.sol";


interface IUniversalRouter {
    /// @notice Executes encoded commands along with provided inputs. Reverts if deadline has expired.
    /// @param commands A set of concatenated commands, each 1 byte in length
    /// @param inputs An array of byte strings containing abi encoded inputs for each command
    /// @param deadline The deadline by which the transaction must be executed
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}

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
        (,uint24 fee) = UniswapV3.getPair(WETH, tokenOut);

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
        (,uint24 fee) = UniswapV3.getPair(tokenIn, tokenOut);
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