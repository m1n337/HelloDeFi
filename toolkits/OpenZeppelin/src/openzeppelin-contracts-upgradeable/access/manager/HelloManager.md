# Manager

## AccessManagedUpgradable

> code: `openzeppelin-contracts-upgradable/contracts/access/manager/AccessManagedUpgradeable.sol`
> https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/manager/AccessManagedUpgradeable.sol

- `restricted`:
    [JUMP] _checkCanCall(_msgSender(), _msgData())

- `_checkCanCall(caller, data)`
    [STATICCALL] authority.canCall(caller, address(this), selector)
    [PASS 1] !immediate + deplay > 0 -> authority.consumeScheduledOp(caller, data)
    [PASS 2] immediate


## AccessManagerUpgradeable

> code: `openzeppelin-contracts-upgradable/contracts/access/manager/AccessManagerUpgradeable.sol`
> https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/access/manager/AccessManagerUpgradeable.sol

ADMIN_ROLE = 0
PUBLIC_ROLE = type(uint64).max

TargetConfig:
    mapping: selector => roleId
    Time.Delay adminDelay
    bool closed

_targets: mapping(address => TargetConfig)


- onlyAuthorized

- ⭐ `canCall(caller, target, selector) -> (immediate, delay)`:
    - isTargetClosed
    - Otherwise: target + selector -- _target[target].allowedRoles[selector] --> roleId  --> hasRole
      - the conditions can call:
        -  `isMember + currentDelay == 0` -> immediate 
        -  `isMember + currentDelay > 0` -> consumeScheduledOp

- `hasRole(roleId, account) -> (isMember, executionDelay)`:
    PUBLIC_ROLE -> (true, 0)
    getAccess

- `getAccess(roleId, account) -> (since, currentDelay, pendingDelay, effect)`:

## Role Level

- `setRoleAdmin`

- `setRoleGuardian`

- `grantRole(roleId, account, executionDelay)`

- `revokeRole(roleId, account)`

- `renounceRole(roleId, callerConfirmation)`

- `getAccess(roleId, account) -> (since, currentDelay, pendingDelay, effect)`

> Note: 
> since: time to get this permission  (grant time + grant delay)
> delay: currentDelay, pendingDelay, effect?

- `labelRole(roleId, label)` -> emit RoleLabel

> Hint: run related tests `forge test --mt test_upgradeable_manager_role_level -vv`

## Contract (Target) Level

- `setTargetClosed(target, closed)`

- `isTargetClosed(target, closed)`


> Hint: run related tests `forge test --mt test_upgradeable_manager_target_level -vv`

## Function Level

- `setTargetFunctionRole(target, []selectors, roleId)`

- `getTargetFunctionRole(target, selector)`

> Hint: run related tests `forge test --mt test_upgradeable_manager_function_level -vv`

## Operations

- `schedule`

- `execute`

- `cancel`


Rule 1: every address is member of the `PUBLIC_ROLE`
Rule 2: every target function is restricted to the `ADMIN_ROLE`

* * A role's admin role via {setRoleAdmin} who can grant or revoke roles.
* * A role's guardian role via {setRoleGuardian} who's allowed to cancel operations.
* * A delay in which a role takes effect after being granted through {setGrantDelay}.
* * A delay of any target's admin action via {setTargetAdminDelay}.
* * A role label for discoverability purposes with {labelRole}.


 * NOTE: This contract implements a form of the {IAuthority} interface, but {canCall} has additional return data so it
 * doesn't inherit `IAuthority`. It is however compatible with the `IAuthority` interface since the first 32 bytes of
 * the return data are a boolean as expected by that interface.
