import {Test, console2} from "forge-std/Test.sol";

import {CloneImpl} from "./HelloClones.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

contract HelloClones is Test {

    address impl;
    function setUp() public {
        impl = address(new HelloClones());
    }

    function test_clone() public {
        address ins = Clones.clone(impl);
        console2.log(Impl(ins).helloClone());
    }
    
}