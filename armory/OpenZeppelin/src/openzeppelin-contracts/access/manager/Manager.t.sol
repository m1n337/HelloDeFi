import {Test, console2} from "hello-fs/Test.sol";
import {AccessManager} from "hello-oz/access/manager/AccessManager.sol";
import {IAccessManager} from "hello-oz/access/manager/IAccessManager.sol";
import {AccessManaged} from "hello-oz/access/manager/AccessManaged.sol";

import {Math} from "hello-oz/utils/math/Math.sol";

contract HelloAccessManagerGame is AccessManaged {
    bool public isPaused;
    mapping(address => uint8) public isPalyer;

    constructor(address _authority) AccessManaged(_authority) {}

    function pause() external restricted {
        isPaused = true;
    }

    function unpause() external restricted {
        delete isPaused;
    }


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

contract TestHelloAccessManager is Test {
    
    address DEV;
    AccessManager manager;

    HelloAccessManagerGame game;

    function setUp() public {
        DEV = makeAddr("DEV");
        
        vm.startPrank(DEV);
        manager = new AccessManager(DEV);
        
        game = new HelloAccessManagerGame(address(manager));
        vm.stopPrank();
    }

    uint64 constant ADMIN_ROLE = 0;
    uint64 constant PLAYER_MANAGER = 1;
    uint64 constant PLAYER_VIP = 2;
    uint64 constant PLAYER_MANAGER_ADMIN = 3;
    uint64 constant PLAYER_MANAGER_GUARDIAN = 4;
    uint64 constant PUBLIC_ROLE = type(uint64).max;
    

    function _print_access(uint64 _r, address _addr) internal {
        (uint48 since, uint32 currentDelay, uint32 pendingDelay, uint48 effect) = manager.getAccess(_r, _addr);
        console2.log("--------------------------------------------------------------");
        console2.log("Access table: %s with Role(#%s):", _addr, _r);
        console2.log(" since = %s", since);
        console2.log(" currentDelay = %s, pendingDelay = %s, effect = %s", currentDelay, pendingDelay, effect);
        console2.log("--------------------------------------------------------------");
    }

    function test_rule() public {

    }

    function _get_delay_effect(uint32 value, uint32 newValue) internal returns(uint48) {
        uint32 minSetback = manager.minSetback();
        uint32 setback = uint32(Math.max(minSetback, value > newValue ? value - newValue : 0));
        uint48 effect = uint48(block.timestamp) + setback;

        return effect;
    }

    function test_access_manager_manage_role() public {
        vm.warp(100000);

        _print_access(ADMIN_ROLE, DEV);
        address player = makeAddr("PLAYER");
        vm.label(player, "PLAYER");
        _print_access(PLAYER_MANAGER, player);
        address player_manager_ = makeAddr("PLAYER_MANAGER");
        vm.label(player_manager_, "PLAYER_MANAGER");
        _print_access(PLAYER_MANAGER, player_manager_);

        console2.log("\n *[Rule] function grantRole: can not grant / revoke PUBLIC_ROLE");
        console2.log("DEV -x-> manager.grantRole(PUBLIC_ROLE, player, 0)");
        vm.prank(DEV);
        vm.expectRevert();
        manager.grantRole(PUBLIC_ROLE, player, 0); 

        
        uint64 player_manager_role_admin = manager.getRoleAdmin(PLAYER_MANAGER);
        console2.log("\n *[Rule] function getRoleAdmin: the global ADMIN_ROLE is the admin role of all other roles by default");
        console2.log("DEV --> manager.grantRole(PLAYER_MANAGER, player_manager_, 0)");
        vm.prank(DEV);
        manager.grantRole(PLAYER_MANAGER, player_manager_, 0);
        _print_access(PLAYER_MANAGER, player_manager_);

        console2.log("DEV --> manager.revokeRole(PLAYER_MANAGER, player_manager)");
        vm.prank(DEV);
        manager.revokeRole(PLAYER_MANAGER, player_manager_);

        vm.prank(DEV);
        manager.grantRole(PLAYER_MANAGER, player_manager_, 0);
        vm.prank(player_manager_);
        manager.renounceRole(PLAYER_MANAGER, player_manager_);
        _print_access(PLAYER_MANAGER, player_manager_);

        vm.prank(DEV);
        manager.setGrantDelay(PLAYER_MANAGER, 2000);
        uint48 grant_delay_effect = _get_delay_effect(0, 2000);
        console2.log("[Before] getRoleGrantDelay(PLAYER_MANAGER) = ", manager.getRoleGrantDelay(PLAYER_MANAGER));
        vm.warp(grant_delay_effect);
        console2.log("[After] getRoleGrantDelay(PLAYER_MANAGER) = ", manager.getRoleGrantDelay(PLAYER_MANAGER));

        vm.prank(DEV);
        manager.grantRole(PLAYER_MANAGER, player_manager_, 0);
        _print_access(PLAYER_MANAGER, player_manager_);
        
        (bool isMember,) = manager.hasRole(PLAYER_MANAGER, player_manager_);
        console2.log("[Before] hasRole(PLAYER_MANAGER, player_manager) = ", isMember);
        console2.log("warp the time until PLAYER_MANAGER role takes effect (now + 2000)");
        vm.warp(block.timestamp + 2000);
        (isMember,) = manager.hasRole(PLAYER_MANAGER, player_manager_);
        console2.log("[After] hasRole(PLAYER_MANAGER, player_manager) = ", isMember);
    
        // setRoleAdmin (the role admin has the previledge to grant / revoke the role to anyone)
        
        // setRoleGuardian (the gradian can cancel an scheduled operation)
        
    }

    function test_manager_role_level_() public {
        _print_access(ADMIN_ROLE, DEV);

        console2.log("DEV --> manager.setTargetFunctionRole(address(game), [HelloAccessManagerGame.play.selector], PUBLIC_ROLE)");
        bytes4[] memory ss = new bytes4[](1);
        ss[0] = HelloAccessManagerGame.play.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(game), ss, PUBLIC_ROLE);
        
        console2.log("DEV --> manager.setTargetFunctionRole(address(game), [HelloAccessManagerGame.specialPlay.selector], PLAYER_VIP)");
        ss[0] = HelloAccessManagerGame.specialPlay.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(game), ss, PLAYER_VIP);
        
        console2.log("DEV --> manager.setTargetFunctionRole(address(game), [HelloAccessManagerGame.removePlayer.selector], PLAYER_MANAGER)");
        ss[0] = HelloAccessManagerGame.removePlayer.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(game), ss, PLAYER_MANAGER);
        
        address user = makeAddr("USER");
        address playerManager = makeAddr("PLAYER_MANAGER");

        console2.log("USER --> game.play()");
        vm.prank(user);
        game.play();
        
        console2.log("\n* [RULE]: a granted role with execution delay must scheudle first\n");
        
        console2.log("USER -x-> game.specialPlay()");
        vm.prank(user);
        vm.expectRevert();
        game.specialPlay();

        console2.log("DEV --> manager.grantRole(PLAYER_VIP, user, 1 hours)");
        vm.warp(10000);
        vm.prank(DEV);
        manager.grantRole(PLAYER_VIP, user, 1 hours);
        
        _print_access(PLAYER_VIP, user);

        console2.log("USER -x-> game.specialPlay()");
        vm.prank(user);
        vm.expectRevert();
        game.specialPlay();

        console2.log("USER -> manager.schedule(address(game), abi.encodeWithSignature(\"specialPlay()\"), 0)");
        vm.prank(user);
        manager.schedule(address(game), abi.encodeWithSignature("specialPlay()"), 0);
        console2.log("After 1 hours ...");
        uint32 oneHoursLatter = uint32(uint256(block.timestamp + 1 hours));
        vm.warp(oneHoursLatter + 1);
        
        console2.log("USER --> game.specialPlay()");
        vm.prank(user);
        game.specialPlay();

        console2.log("=> isPlayer[USER] = ", game.isPalyer(user));

        // set grant delay

    }
    
    function test_upgradeable_manager_target_level() public {
        console2.log("DEV --> game.pause()");
        vm.prank(DEV);
        game.pause();

        console2.log("DEV --> game.unpause()");
        vm.prank(DEV);
        game.unpause();
        
        console2.log("DEV --> manager.setTargetClosed(address(game), true)");
        vm.prank(DEV);
        manager.setTargetClosed(address(game), true);


        console2.log("DEV -x-> game.pause()");
        console2.log("\n* [RULE]: when the target is closed, all restricted functions can not be called even admin\n");
        vm.prank(DEV);
        vm.expectRevert();
        game.pause();

        console2.log("DEV --> manager.setTargetClosed(address(game), false)");
        console2.log("\n* [RULE]: a target contract closed could be reopened latter.\n");
        vm.prank(DEV);
        manager.setTargetClosed(address(game), false);

        console2.log("DEV --> game.pause()");
        vm.prank(DEV);
        game.pause();    
    }

    function test_upgradeable_manager_function_level() public {
        address user = makeAddr("USER");
        
        console2.log("USER -x-> game.play()");
        console2.log("\n* [RULE]: normal user can not call restricted functions by default.\n");
        vm.prank(user);
        // vm.expectRevert();
        vm.expectRevert();
        game.play();

        console2.log("Open the `play` function for PUBLIC_ROLE...");
        console2.log("DEV --> manager.setTargetFunctionRole(address(game), ss, type(uint64).max)");
        bytes4[] memory ss = new bytes4[](1);
        ss[0] = HelloAccessManagerGame.play.selector;
        vm.prank(DEV);
        manager.setTargetFunctionRole(address(game), ss, type(uint64).max);

        console2.log("USER --> game.play()");
        vm.prank(user);
        game.play();

        console2.log("=> isPlayer[USER] = ", game.isPalyer(user));
    }
}