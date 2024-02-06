import {IERC20} from 'hello-oz/token/ERC20/IERC20.sol';

import {UniswapV3_Factory as Factory} from "evm-address/dapps/UniswapV3.sol";

import { PoolAddress } from '../v3/libraries/PoolAddress.sol';

library UniswapV3Plus {

    struct FeesTickSpacing {
        uint24 fee;
        int24 tickSpacing;
    }

    /**
     * @dev Helper function which saved the current fees that was available in the factory
     * @return fees a struct of fees that was available in the factory
     */
    function getFees() internal pure returns (FeesTickSpacing[] memory) {
        FeesTickSpacing[] memory fees = new FeesTickSpacing[](4);
        fees[0] = FeesTickSpacing(100, 1);
        fees[1] = FeesTickSpacing(500, 10);
        fees[2] = FeesTickSpacing(3000, 60);
        fees[3] = FeesTickSpacing(10000, 200);
        return fees;
    }
    
    function getPair(address _token0, address _token1) internal returns(address, uint24) {
        address _factory = Factory.select();
        return _getPair(_factory, _token0, _token1);
    }

    function _getPair(address _factory, address _token0, address _token1) internal returns(address, uint24) {
        FeesTickSpacing[] memory _fees = getFees();

        address _bestPool;
        uint24 _bestPoolFee;
        uint256 _k;
        for (uint256 i; i < _fees.length; i++) {
            PoolAddress.PoolKey memory _pk = PoolAddress.getPoolKey(_token0, _token1, _fees[i].fee);
            address _pair = PoolAddress.computeAddress(_factory, _pk);
            uint256 _ck = IERC20(_token0).balanceOf(_pair) * IERC20(_token1).balanceOf(_pair);
            if (_ck <= _k) continue;
            _k = _ck;
            _bestPool = _pair;
            _bestPoolFee = _fees[i].fee;
        }

        return (_bestPool, _bestPoolFee);
    }
}