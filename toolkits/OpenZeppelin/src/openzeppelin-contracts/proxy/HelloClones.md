> code: `openzeppelin-contracts/contracts/proxy/Clones.sol`
> https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.1/contracts/proxy/Clones.sol

- function `clone`:

mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))

```text
# 0x60 = 96 bits (256 - 96 = 160 = 40 hex = 20 bytes) ( => 0x<implementation>00..00 )
# 0xe8 = 232 bits ( => 0x00..00<implementation[:6]> )
mstore: store `0x00..003d602d80600a3d3981f3363d3d373d3d3d363d73<implementation[:6]>` into mem[0x0]
```

mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))

```text
# 0x78 = 120 (40-120) bits ( => 0x<implementation[6:]>00..00 )
# len('5af43d82803e903d91602b57fd5bf3') = 30 = 15 bytes = 120 bits
mstore: store `0x<implementation[6:]>5af43d82803e903d91602b57fd5bf3` into mem[0x20]
```

Now the entire memory is as follows (with the implementation: 0x1234567891234567891234567891234567891234):"

```base
0x00: 0000000000000000003d602d80600a3d3981f3363d3d373d3d3d363d73123456
0x20: 78912345678912345678912345678912345af43d82803e903d91602b57fd5bf3
```

Now, let's prove it in `chisel`:

```bash
➜ address implementation = 0x1234567891234567891234567891234567891234;
➜ assembly {
mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
}
➜ !md
[0x00:0x20]: 0x0000000000000000003d602d80600a3d3981f3363d3d373d3d3d363d73123456
[0x20:0x40]: 0x78912345678912345678912345678912345af43d82803e903d91602b57fd5bf3
[0x40:0x60]: 0x0000000000000000000000000000000000000000000000000000000000000080
```

instance := create(0, 0x09, 0x37)

> Hint: create(v, p, n):
> create new contract with code mem[p…(p+n)) and send v wei and return the new address; returns 0 on error

```text
# 0x09 = 9 bytes = 72 bits = 18 hex (len("0x000000000000000000") = 18) ( => code_start )
# 0x09 + 0x37 = 0x40 ( => code_end )
code = 3d602d80600a3d3981f3363d3d373d3d3d363d73<1234567891234567891234567891234567891234>5af43d82803e903d91602b57fd5bf3
```

Let's dive into the "code" we created. 
First, you can disassemble the bytecodes with the command `cast da <code>`. Here's the results look:

```bash
00000000: RETURNDATASIZE    # just the alias of `push 0`
# !sd stack = [0x0
00000001: PUSH1 0x2d        # 0x2d = 45, which maybe means the code_size?
# !sd stack = [0x0 0x2d
00000003: DUP1
# !sd stack = [0x0 0x2d 0x2d
00000004: PUSH1 0xa
# !sd stack = [0x0 0x2d 0x2d 0xa
00000006: RETURNDATASIZE
# !sd stack = [0x0 0x2d 0x2d 0xa 0x0
00000007: CODECOPY          
# CODECOPY: copy code[offset:offset+size] into the mem[dest:dest+size]
# where dest = stack[-1], offset = stack[-2], size = stack[-3] (i.e. dest = 0x0, offset = 0xa. size = 0x2d)
# !sd stack = [0x0 0x2d
00000008: DUP2
# !sd stack = [0x0 0x2d 0x0
00000009: RETURN
# RETURN: copy mem[offset:offset+size] into the return_data
# where offset = stack[-1], size = stack[-2] (i.e. offset = 0x0, size = 0x2d)
# mem[0x0:0x2d] = code[0x0a:0x0a+0x2d], oops, just the following code, right
# !sd stack = [0x0

# ------------------------------------ Separator ------------------------------------
# the following codes are results returned.
# It is referred to as `runtime code`, representing the actual logic of the smart contract executed in the EVM.
0000000a: CALLDATASIZE      
# !sd stack = [calldata_size
0000000b: RETURNDATASIZE
# !sd stack = [calldata_size, 0x0
0000000c: RETURNDATASIZE    
# !sd stack = [calldata_size, 0x0, 0x0
0000000d: CALLDATACOPY      
# !sd stack = [
# copy entire calldata into the mem[0x0]
0000000e: RETURNDATASIZE    
# !sd stack = [0x0
0000000f: RETURNDATASIZE    
# !sd stack = [0x0, 0x0
00000010: RETURNDATASIZE    
# !sd stack = [0x0, 0x0, 0x0
00000011: CALLDATASIZE
# !sd stack = [0x0, 0x0, 0x0, calldata_size
00000012: RETURNDATASIZE
# !sd stack = [0x0, 0x0, 0x0, calldata_size, 0x0
00000013: PUSH20 0x1234567891234567891234567891234567891234
# !sd stack = [0x0, 0x0, 0x0, calldata_size, 0x0, 0x1234567891234567891234567891234567891234
00000028: GAS
# !sd stack = [0x0, 0x0, 0x0, calldata_size, 0x0, 0x1234567891234567891234567891234567891234, gas()
00000029: DELEGATECALL
# !sd stack = [0x0, succ
# delegatecall gas() 0x1234567891234567891234567891234567891234     0x0         calldata_size       0x0            0x0
#                               impl                            args_offset       args_size     rets_offset     rets_size
0000002a: RETURNDATASIZE
# !sd stack = [0x0, succ, ret_size
0000002b: DUP3
# !sd stack = [0x0, succ, ret_size, 0x0
0000002c: DUP1
# !sd stack = [0x0, succ, ret_size, 0x0, 0x0
0000002d: RETURNDATACOPY
# !sd stack = [0x0, succ
# copy ret_data[0x0:ret_size] into mem[0x0]
0000002e: SWAP1
# !sd stack = [succ, 0x0
0000002f: RETURNDATASIZE
# !sd stack = [succ, 0x0, ret_size
00000030: SWAP2
# !sd stack = [ret_size, 0x0, succ
00000031: PUSH1 0x2b
# !sd stack = [ret_size, 0x0, succ, 0x2b
00000033: JUMPI
# !sd stack = [ret_size, 0x0
# jump to 0x2b if succ is true
# Hint: Why is 0x2b used? Within the entire code, the pc 0x34 corresponds to 0x2b in the runtime code (start from 0xa).
00000034: REVERT
# revert mem[0x0:ret_size]
00000035: JUMPDEST
00000036: RETURN
# return mem[0x0:ret_size]
```

Hint: the address of CREATE is: `keccak(RLP(creator, nonce))[12:]`

Note: Solidity not support RLP encode

- cloneDeterministic: the CREATE2 version of the clone

Hint: the address of CREATE2 is: `keccak256( 0xff ++ creator ++ salt ++ keccak256(init_code))[12:]`

- predictDeterministicAddress: predict the address created with `cloneDeterministic`

