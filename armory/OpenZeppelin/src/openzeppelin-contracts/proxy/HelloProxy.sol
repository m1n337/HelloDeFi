contract CloneImpl {
    function helloClone() external returns(string memory) {
        return "Hello Clone";
    }
}

import {Test, console2} from "forge-std/Test.sol";
import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";

contract HelloClones is Test {

    address impl;
    function setUp() public {
        impl = address(new CloneImpl());
    }

    function test_clone() public {
        address ins = Clones.clone(impl);
        console2.log(CloneImpl(ins).helloClone());
    }
    
}