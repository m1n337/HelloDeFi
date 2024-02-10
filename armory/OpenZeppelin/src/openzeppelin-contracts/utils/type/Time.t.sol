import {Test, console2} from "hello-fs/Test.sol";
import {Time} from "hello-oz/utils/types/Time.sol";

contract TestHelloOZTime is Test {
    using Time for Time.Delay;

    function test_access_time_info() external {
        uint48 stmp = Time.timestamp();
        uint48 bn = Time.blockNumber();

        console2.log("Time.timestamp() = %s (block.timestamp = %s)", stmp, block.timestamp);
        console2.log("Time.blockNumber() = %s (block.blockNumber = %s)", bn, block.number);
    }

    function test_time_delay_instantiation() external {
        Time.Delay delay = Time.pack(1 hours, 2 hours, Time.timestamp() + 1 minutes);
        console2.log("creates a delay Time.pack(valueBefore = 1 hours (3600), valueAfter = 2 hours (7200), effect = Time.timestamp() + 1 minutes)");
        console2.logBytes(abi.encodePacked(delay));
        console2.log("delay.get() = %s @time=%s", delay.get(), block.timestamp);
        
        console2.log("vm.warp(Time.tempstamp() + 1 minutes): to fast forward time to when the delay takes effect");
        vm.warp(Time.timestamp() + 1 minutes);

        console2.log("delay.get() = %s @time=%s", delay.get(), block.timestamp);

        Time.Delay delay2 = Time.toDelay(1 hours);
        console2.log("creates another delay2 Time.toDelay(1 hours)");
        console2.logBytes(abi.encodePacked(delay2));
        
        console2.log("delay2.get() = %s @time=%s", delay2.get(), block.timestamp);
        
        console2.log("\n* [Rule]: the toDelay function creates a 'delay' to 'pending' status by default, but it takes effect due to the effect is ZERO.");
    }

    function test_updates_time_delay() external {
        Time.Delay delay = Time.pack(1 hours, 2 hours, Time.timestamp() + 1 minutes);
        console2.log("creates a delay Time.pack(valueBefore = 1 hours (3600), valueAfter = 2 hours (7200), effect = Time.timestamp() + 1 minutes)");
        console2.logBytes(abi.encodePacked(delay));
        console2.log("delay.get() = %s @time=%s", delay.get(), block.timestamp);
        
        (,,uint48 _effect) = delay.unpack();
        console2.log("effect before update is %s", _effect);
        (,_effect) = delay.withUpdate(0, 0);
        console2.log("\n* [Case 1: `small minSetBack & newValue`] delay.withUpdate(0, 0) -> effect = %s\n", _effect);

        uint32 _oldEffect = uint32(Time.timestamp() + 1 minutes);
        delay = Time.pack(1 hours, 2 hours, _oldEffect);
        console2.log("creates a delay Time.pack(valueBefore = 1 hours (3600), valueAfter = 2 hours (7200), effect = Time.timestamp() + 1 minutes)");
        console2.logBytes(abi.encodePacked(delay));
        console2.log("delay.get() = %s @time=%s", delay.get(), block.timestamp);
        console2.log("vm.warp(Time.tempstamp() + 1 minutes): to fast forward time to when the delay takes effect");
        vm.warp(Time.timestamp() + 1 minutes);
        uint32 _delayDuration = delay.get();
        console2.log("delay.get() = %s @time=%s", _delayDuration, block.timestamp);

        (,_effect) = delay.withUpdate(0, _delayDuration + 2);
        console2.log("\n* [Case 2: `larger minSetBack`] delay.withUpdate(0, _delayDuration+2) -> effect = %s\n", _effect);

        delay = Time.pack(1 hours, 2 hours, Time.timestamp() + 1 minutes);
        console2.log("creates a delay Time.pack(valueBefore = 1 hours (3600), valueAfter = 2 hours (7200), effect = Time.timestamp() + 1 minutes)");
        console2.logBytes(abi.encodePacked(delay));
        console2.log("delay.get() = %s @time=%s", delay.get(), block.timestamp);
        (,_effect) = delay.withUpdate(30 minutes, 0);
        console2.log("\n* [Case 3: `smaller minSetBack and new half delay`] delay.withUpdate(valueBefore / 2, 0) -> effect = %s\n", _effect);
    }
}
