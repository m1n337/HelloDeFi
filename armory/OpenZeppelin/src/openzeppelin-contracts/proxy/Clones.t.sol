import {Test, console2} from "hello-fs/Test.sol";
import {Clones} from "hello-oz/proxy/Clones.sol";

contract CloneImpl {
    function helloClone() external returns(string memory) {
        return "Hello Clone";
    }
}

contract HelloClones is Test {

    address impl;
    function setUp() public {
        impl = address(new CloneImpl());
    }

    function test_oz_proxy_clones() public {
        console2.log("[CALL] Clones.clone(impl)");
        address ins = Clones.clone(impl);
        console2.log("[CALL] CloneImpl(_).helloClone(): ", CloneImpl(ins).helloClone());
    }

    function test_oz_proxy_clones_deterministic() public {
        console2.log("[CALL] Clones.cloneDeterministic(impl, \"i'm the salt\")");
        address ins = Clones.cloneDeterministic(impl, "i'm the salt");
        console2.log("The address of the contract cloned is: ", ins);
        console2.log("[CALL] CloneImpl(_).helloClone(): ", CloneImpl(ins).helloClone());
        
        address pred = Clones.predictDeterministicAddress(impl, "i'm the salt");
        console2.log("[STATICCALL] Clones.predictDeterministicAddress(impl, \"i'm the salt\"): ", pred);
    }
}