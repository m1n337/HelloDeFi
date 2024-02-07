# Cast

Cast is a useful toolkit provided by the foundry. However, there are so many commands for this tool. This note is a classification for these commands according to their requirement and functionality.

## Utils (No provider needed)

|**constant**|alias|
|-----|-----|
|`address-zero` |`az`|
|`hash-zero`    |`hz`|
|`max-int`      |`maxi`|
|`min-int`      |`mini`|
|`max-uint`     |`maxu`|


|**operation**|alias|
|-------|-------|
|`shl`,`shr`| -|
|`concat-hex`|`ch`|
|`keccak`|`k`|
|`index`|-|
|`compute-address`|`ca`|
|`create2`|`c2`|
|`sig`,`sig-event`|-|
|`calldata`|`cd`|
|`calldata-decode`|`cdd`|
|`pretty-calldata`|`pc`|
|`abi-encode`|`ae`|
|`abi-decode`|`ad`|
|`bind`|`bi`|
|`disassemble`|`da`|
|`logs`|`l`|
|`namehash`|-|


|**convertion**| alice |
|-------|-------|
|`to-ascii`|`2as` |
|`to-base`| -|
|`to-bytes32`| -|
|`to-check-sum-address`|`ta`|
|`to-dec`|-|
|`to-fixed-point`|-|
|`to-hex`| - |
|`to-hexdata`| - |
|`to-int256`| - |
|`to-rlp`| - |
|`to-uint256`| - |
|`to-unit`| - |
|`to-wei`| `2w` |
|`format-bytes32-string`| - |
|`parse-bytes32-string`| - |
|`parse-bytes32-address`| - |
|`from-bin`              | - |
|`from-fixed-point`      | - |
|`from-rlp`              | - |
|`from-utf8`             | - |
|`from-wei`              | - |

|**query**|alias|
|-------|------|
|`4byte`|`4`|
|`4byte-deoode`|`4d`|
|`4byte-event`|`4e`|

## Eth
|**blockchain state**| alias |
|---------------|-------|
|`chain`|-|
|`chain-id`|`cid`|
|`block`|`bl`| 
|`block-number`|`bn`|
|`find-block`|`f`|
|`age`|`a`|
|`blanace`|`b`|
|`base-fee`|`fee`|
|`gas-price`|`g`|

|**contract state**| alias |
|------------------|-------|
|`access-list`|`ac`|
|`admin`|-|
|`implementation`|`impl`|
|`storage`|-|

|**code**|alias|
|--------|-----|
|`code`|-|
|`codesize`|-|
|`etherscan-source`|`et`|
|⭐ `interface`|`i`|

|**account**|alias|
|-----------|-----|
|`nonce`|`n`|
|`proof`|`pr`|
|`wallet`|`w`|

|**tx**|alias|
|------|-----|
|⭐ `decode-transaction`|`dt`|
|`estimate`|-|
|`receipt`|`re`|
|⭐ `tx`|`t`|
|⭐ `run`|`r`|

|**operation**|alias|
|-------------|-----|
|⭐ `rpc`|-|
|⭐ `call`|`c`|
|⭐ `publish`|`p`|
|⭐⭐ `send`|`s`|