pragma solidity ^0.4.24;

import "../access/roles/PauserRole.sol";
import "../access/roles/UnpauserRole.sol";

/**
 * @title Pausable
 *
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * This contract inherits the PauserRole contract to use RBAC for administering accounts that can pause.
 * This contract inherits the UnpauserRole contract to use RBAC for administering accounts that can unpause.
 */
contract Pausable is PauserRole, UnpauserRole {
    /** Whether or not contract functionality is paused. */
    bool private _paused;

    /** Event emitted whenever the contract is set to the paused state. */
    event Paused(address indexed pauser);

    /** Event emitted whenever the contract is unset from the paused state. */
    event Unpaused(address indexed unpauser);

    /**
     * @dev Modifier to make a function callable only when the caller has access to the pauser role or the owner role.
     */
    modifier onlyPauserOrOwner() {
        require(super._isPauser(msg.sender) || super._isOwner(msg.sender));
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the caller has access to the unpauser role or the owner role.
     */
    modifier onlyUnpauserOrOwner() {
        require(super._isUnpauser(msg.sender) || super._isOwner(msg.sender));
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev Query whether the contract is paused or not.
     *
     * @return True if the contract is paused, otherwise false
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Pauses by setting `_paused` to true, to trigger stopped state.
     * Callable by an account with the pauser role, or an account with the owner role.
     */
    function pause() external onlyPauserOrOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Unpauses by setting `_paused` to false, to return to normal state.
     * Callable by an account with the unpauser role, or an account with the owner role.
     */
    function unpause() external onlyUnpauserOrOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}