import {Test, console2} from "forge-std/Test.sol";

import {OneInchNetwork_AggregationRouterV5} from "evm-address/dapps/OneInchNetwork.sol";

contract Hello_1inchNetwork_AggregationRouterV5 is Test {
    address private aggV5;

    function setUp() public {
        aggV5 = OneInchNetwork_AggregationRouterV5.select();
    }

    function test_ini() public {
        console2.log(aggV5);
    }
}