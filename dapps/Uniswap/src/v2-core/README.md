The v2-core repo implemented the main functionalities of the UniswapV2 DEX, which includes a `UniswapV2Factory` contract and a `UniswapV2Pair` contract.

The permissionless feature enables users to launch a new pair by calling the `createPair` function in the `UniswapV2Factory` contract.

New pairs are created and initialized using the `UniswapV2Pair` contract code and recorded in the `UniswapV2Factory`.

As for the `UniswapV2Pair` contract, we first talk about three important functions `mint`, `burn` and `swap`.

When we talk about DEX, we talk about exchange in real. However, no like CEX or the exchanges in the real world, the

