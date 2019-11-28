pragma solidity ^0.4.24;

import "../Roles.sol";
import "./PauserAdminRole.sol";

/**
 * @title UnpauserRole
 *
 * @dev Role for providing access control to functions that unpause contract functionality.
 * This contract inherits from PauserAdminRole so that pauserAdmins can administer this role.
 */
contract UnpauserRole is PauserAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the unpauser role. */
    event UnpauserAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the unpauser role. */
    event UnpauserRemoved(address indexed account);

    /** Mapping of account addresses with access to the unpauser role. */
    Roles.Role private _unpausers;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the unpauser role.
     */
    modifier onlyUnpauser() {
        require(_isUnpauser(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the unpauser role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the unpauser role, otherwise false
     */
    function isUnpauser(address account) external view returns (bool) {
        return _isUnpauser(account);
    }

    /**
     * @return The number of account addresses with access to the unpauser role.
     */
    function numberOfUnpausers() external view returns (uint256) {
        return _unpausers.size();
    }

    /**
     * @return An array containing all account addresses with access to the unpauser role.
     */
    function unpausers() external view returns (address[]) {
        return _unpausers.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the unpauser role.
     * Callable by an account with the pauserAdmin role.
     *
     * @param account The account address being given access to the unpauser role
     */
    function addUnpauser(address account) external onlyPauserAdmin {
        _addUnpauser(account);
    }

    /**
     * @dev Remove access to the unpauser role for the given `account`.
     * Callable by an account with the pauserAdmin role.
     *
     * @param account The account address having access removed from the unpauser role
     */
    function removeUnpauser(address account) external onlyPauserAdmin {
        _removeUnpauser(account);
    }

    /**
     * @dev Remove access to the unpauser role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the unpauserAdmin role.
     *
     * @param previousAccount The account address having access removed from the unpauser role
     * @param newAccount The account address being given access to the unpauser role
     */
    function replaceUnpauser(address previousAccount, address newAccount) external onlyPauserAdmin {
        _replaceUnpauser(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the unpauser role with the given array of `accounts`.
     * Callable by an account with the unpauserAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing unpausers with
     */
    function replaceAllUnpausers(address[] accounts) external onlyPauserAdmin {
        _replaceAllUnpausers(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_unpausers`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_unpausers`, otherwise false
     */
    function _isUnpauser(address account) internal view returns (bool) {
        return _unpausers.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_unpausers`.
     * Emits a UnpauserAdded event.
     *
     * @param account The account address being given access to the unpauser role
     */
    function _addUnpauser(address account) internal {
        _unpausers.add(account);
        emit UnpauserAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_unpausers`.
     * Emits a UnpauserRemoved event.
     *
     * @param account The account address having access removed from the unpauser role
     */
    function _removeUnpauser(address account) internal {
        _unpausers.remove(account);
        emit UnpauserRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_unpausers` with the `newAccount`.
     * Emits a UnpauserRemoved event.
     * Emits a UnpauserAdded event.
     *
     * @param previousAccount The account address having access removed from the unpauser role
     * @param newAccount The account address being given access to the unpauser role
     */
    function _replaceUnpauser(address previousAccount, address newAccount) internal {
        _unpausers.replace(previousAccount, newAccount);
        emit UnpauserRemoved(previousAccount);
        emit UnpauserAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_unpausers` with the given array of `accounts`.
     * Emits a UnpauserAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a UnpauserRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing unpausers with
     */
    function _replaceAllUnpausers(address[] accounts) internal {
        // Emit a UnpauserAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_unpausers.has(accounts[i])) {
                emit UnpauserAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _unpausers.replaceAll(accounts);

        // Emit a UnpauserRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_unpausers.has(previousAccounts[j])) {
                emit UnpauserRemoved(previousAccounts[j]);
            }
        }
    }
}