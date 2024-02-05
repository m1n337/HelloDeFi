
import {Test, console2} from "hello-fs/Test.sol";

import { AccessManagedUpgradeable } from "hello-uoz/access/manager/AccessManagedUpgradeable.sol";
import {ERC1967Proxy} from "hello-oz/proxy/ERC1967/ERC1967Proxy.sol";
import {AccessManager} from "hello-oz/access/manager/AccessManager.sol";


contract HelloManager is AccessManagedUpgradeable {
    bool public isPaused;
    function initialize(
        address _authority
    ) external initializer {
        __AccessManaged_init(_authority);
    }
    function pause() external restricted {
        isPaused = true;
    }

    function unpause() external restricted {
        delete isPaused;
    }

    mapping(address => uint8) public isPalyer;

    // @notice play function needs the PUBLIC_ROLE
    function play() external restricted {
        isPalyer[msg.sender] = 1;
    }

    // @notice specialPlay function needs the Role PLAYER_VIP(#2)
    function specialPlay() external restricted {
        isPalyer[msg.sender] = 2;
    }

    // @notice removePlayer function needs the Role PLAYER_MANAGER(#1)
    function removePlayer(address _p) external restricted {
        isPalyer[_p] = 0;
    }
}

contract HelloManagerTest is Test {
    HelloManager proxy;
    address HelloManagerImpl;
    AccessManager manager;

    address DEV;

    function setUp() public {
        DEV = makeAddr("DEV");
        vm.startPrank(DEV);

        HelloManagerImpl = address(new HelloManager());
        manager = new AccessManager(DEV);

        proxy = HelloManager(address(new ERC1967Proxy(HelloManagerImpl, abi.encodeWithSelector(HelloManager.initialize.selector, address(manager)))));
        
        vm.stopPrank();
    }

    uint64 constant PLAYER_MANAGER = 1;
    uint64 constant PLAYER_VIP = 2;
    uint64 constant ADMIN_ROLE = 0;
    uint64 constant PUBLIC_ROLE = type(uint64).max;
    

    function _print_access(uint64 _r, address _addr) internal {
        (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) = manager.getAccess(_r, _addr);
        console2.log("--------------------------------------------------------------");
        console2.log("Access table: %s with Role(#%s):", _addr, _r);
        console2.log(" since = %s", since);
        console2.log(" currentDelay = %s, pendingDelay = %s, effect = %s", currentDelay, pendingDelay, effect);
        console2.log("--------------------------------------------------------------");
    }

    function test_upgradeable_manager_role_level() public {
        _print_access(ADMIN_ROLE, DEV);

        console2.log("DEV --> manager.setTargetFunctionRole(address(proxy), [HelloManager.play.selector], PUBLIC_ROLE)");
        bytes4[] memory ss = new bytes4[](1);
        ss[0] = HelloManager.play.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(proxy), ss, PUBLIC_ROLE);
        
        console2.log("DEV --> manager.setTargetFunctionRole(address(proxy), [HelloManager.specialPlay.selector], PLAYER_VIP)");
        ss[0] = HelloManager.specialPlay.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(proxy), ss, PLAYER_VIP);
        
        console2.log("DEV --> manager.setTargetFunctionRole(address(proxy), [HelloManager.removePlayer.selector], PLAYER_MANAGER)");
        ss[0] = HelloManager.removePlayer.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(proxy), ss, PLAYER_MANAGER);
        
        address user = makeAddr("USER");
        address playerManager = makeAddr("PLAYER_MANAGER");

        console2.log("USER --> proxy.play()");
        vm.prank(user);
        proxy.play();


        console2.log("USER -x-> proxy.specialPlay()");
        vm.prank(user);
        vm.expectRevert();
        proxy.specialPlay();

        vm.warp(10000);
        vm.prank(DEV);
        manager.grantRole(PLAYER_VIP, user, 1 hours);
        
        _print_access(PLAYER_VIP, user);
        console2.log("After 1 hours ...");
        uint32 oneHoursLatter = uint32(uint256(block.timestamp + 1 hours));
        vm.warp(oneHoursLatter + 1);
        console2.log(block.timestamp);
        _print_access(PLAYER_VIP, user);

        console2.log("USER --> proxy.specialPlay()");
        vm.prank(user);
        proxy.specialPlay();


        // set grant delay
        
    }
    
    function test_upgradeable_manager_target_level() public {
        console2.log("DEV --> proxy.pause()");
        vm.prank(DEV);
        proxy.pause();

        console2.log("DEV --> proxy.unpause()");
        vm.prank(DEV);
        proxy.unpause();
        
        console2.log("DEV --> manager.setTargetClosed(address(proxy), true)");
        vm.prank(DEV);
        manager.setTargetClosed(address(proxy), true);


        console2.log("DEV -x-> proxy.pause()");
        console2.log("\n* [RULE]: when the target is closed, all restricted functions can not be called even admin\n");
        vm.prank(DEV);
        vm.expectRevert();
        proxy.pause();

        console2.log("DEV --> manager.setTargetClosed(address(proxy), false)");
        console2.log("\n* [RULE]: a target contract closed could be reopened latter.\n");
        vm.prank(DEV);
        manager.setTargetClosed(address(proxy), false);

        console2.log("DEV --> proxy.pause()");
        vm.prank(DEV);
        proxy.pause();    
    }

    function test_upgradeable_manager_function_level() public {
        address user = makeAddr("USER");
        
        console2.log("USER -x-> proxy.play()");
        console2.log("\n* [RULE]: normal user can not call restricted functions by default.\n");
        vm.prank(user);
        // vm.expectRevert();
        vm.expectRevert();
        proxy.play();

        console2.log("Open the `play` function for PUBLIC_ROLE...");
        console2.log("DEV --> manager.setTargetFunctionRole(address(proxy), ss, type(uint64).max)");
        bytes4[] memory ss = new bytes4[](1);
        ss[0] = HelloManager.play.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(proxy), ss, type(uint64).max);

        console2.log("USER --> proxy.play()");
        vm.prank(user);
        proxy.play();

        console2.log("=> isPlayer[USER] = ", proxy.isPalyer(user));
    }
}