import { PoolAddress } from './libraries/PoolAddress.sol';

import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

library UniswapV3 {
    address constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

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
        FeesTickSpacing[] memory _fees = getFees();

        address _bestPool;
        uint24 _bestPoolFee;
        uint256 _k;
        for (uint256 i; i < _fees.length; i++) {
            PoolAddress.PoolKey memory _pk = PoolAddress.getPoolKey(_token0, _token1, _fees[i].fee);
            address _pair = PoolAddress.computeAddress(FACTORY, _pk);
            uint256 _ck = IERC20(_token0).balanceOf(_pair) * IERC20(_token1).balanceOf(_pair);
            if (_ck <= _k) continue;
            _k = _ck;
            _bestPool = _pair;
            _bestPoolFee = _fees[i].fee;
        }

        return (_bestPool, _bestPoolFee);
    }
}