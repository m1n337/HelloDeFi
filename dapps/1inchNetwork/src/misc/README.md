## AggregationRouterV5

contracts/routers/ClipperRouter.sol

- [x] Note 1: use 0x0 as the address of native _ETH.

- clipperSwapTo: 
  
Native ETH: 
1. just check `msg.value = inputAmount` (Err: `InvalidMsgValue`)
2. $\rightarrow$ clipperExchange.sellEthForToken{value: inputAmount}(address(dstToken), inputAmount, outputAmount, goodUntil, recipient, signature, _INCH_TAG);
    ```solidity
    assembly { // solhint-disable-line no-inline-assembly
        let ptr := mload(0x40)

        mstore(ptr, selector) 
        mstore(add(ptr, 0x04), dstToken)
        mstore(add(ptr, 0x24), inputAmount)
        mstore(add(ptr, 0x44), outputAmount)
        mstore(add(ptr, 0x64), goodUntil)
        mstore(add(ptr, 0x84), recipient)
        mstore(add(ptr, 0xa4), add(27, shr(_SIGNATURE_V_SHIFT, vs)))
        mstore(add(ptr, 0xc4), r)
        mstore(add(ptr, 0xe4), and(vs, _SIGNATURE_S_MASK))
        mstore(add(ptr, 0x104), 0x120)
        mstore(add(ptr, 0x143), _INCH_TAG_WITH_LENGTH_PREFIX)
        if iszero(call(gas(), clipper, inputAmount, ptr, 0x149, 0, 0)) {
            returndatacopy(ptr, 0, returndatasize())
            revert(ptr, returndatasize())
        }
    }
    ```
    > call(g, t, v, in, insize, out, outsize)
    > target.call{gas: g, value: v}(mem[in..(in+insize)]) -> success
    > side effect: return / failure data = mem[out...(out+outsize)]
    >   rule 1: data_size > outsize: mem[out...(out+outsize)] + returndatacopy
    >   rule 2: data_size < outsize: mem[out...(out+returndatasize)]

WETH: 
Others (ERC20):

EIP712

Ownable

ClipperRouter

GenericRouter

UnoswapRouter

UnoswapV3Router

OrderMixin

OrderRFQMixin