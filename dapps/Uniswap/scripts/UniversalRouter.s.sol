// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "hello-fs/Script.sol";


import { UniversalRouter } from '../src/universal-router-plus/index.sol';
import { IUniversalRouter } from '../src/universal-router/interfaces/IUniversalRouter.sol';

contract UniversalRouterSwapScript is Script {
    using UniversalRouter for UniversalRouter.ExecuteParam;

    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    address constant USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;

    address constant ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    address constant QUOTERV2 = 0x61fFE014bA17989E743c5F6cB21bF9697530B21e;

    function run() public {
        // uint256 pk = vm.envUint("PK");
        uint256 pk = vm.envUint("PK");
        address me = vm.addr(pk);

        uint256 ethBefore = me.balance;
        console2.log("[LOG] account = %s", me);
        console2.log("balance = ", ethBefore);
        vm.startBroadcast();
        UniversalRouter.simpleSwapEthForExactTokens(pk, GMX, 1e18);
        vm.stopBroadcast();
        uint256 ethAfter = me.balance;
        console2.log("Buy 1 GMX using %s ETH", ethBefore - ethAfter);
    }
}
