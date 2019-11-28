pragma solidity ^0.4.24;

import "../Roles.sol";
import "./OwnerRole.sol";

/**
 * @title PauserAdminRole
 *
 * @dev Role for providing access control to functions that administer individual pauser roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The PauserRole contract should inherit from this contract.
 */
contract PauserAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the pauserAdmin role. */
    event PauserAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the pauserAdmin role. */
    event PauserAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the pauserAdmin role. */
    Roles.Role private _pauserAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the pauserAdmin role.
     */
    modifier onlyPauserAdmin() {
        require(_isPauserAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the pauserAdmin role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the pauserAdmin role, otherwise false
     */
    function isPauserAdmin(address account) external view returns (bool) {
        return _isPauserAdmin(account);
    }

    /**
     * @return The number of account addresses with access to the pauserAdmin role.
     */
    function numberOfPauserAdmins() external view returns (uint256) {
        return _pauserAdmins.size();
    }

    /**
     * @return An array containing all account addresses with access to the pauserAdmin role.
     */
    function pauserAdmins() external view returns (address[]) {
        return _pauserAdmins.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the pauserAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the pauserAdmin role
     */
    function addPauserAdmin(address account) external onlyOwner {
        _addPauserAdmin(account);
    }

    /**
     * @dev Remove access to the pauserAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the pauserAdmin role
     */
    function removePauserAdmin(address account) external onlyOwner {
        _removePauserAdmin(account);
    }

    /**
     * @dev Remove access to the pauserAdmin role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the owner role.
     *
     * @param previousAccount The account address having access removed from the pauserAdmin role
     * @param newAccount The account address being given access to the pauserAdmin role
     */
    function replacePauserAdmin(address previousAccount, address newAccount) external onlyOwner {
        _replacePauserAdmin(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the pauserAdmin role with the given array of `accounts`.
     * Callable by an account with the owner role.
     *
     * @param accounts An array of account addresses to replace all existing pauserAdmins with
     */
    function replaceAllPauserAdmins(address[] accounts) external onlyOwner {
        _replaceAllPauserAdmins(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_pauserAdmins`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_pauserAdmins`, otherwise false
     */
    function _isPauserAdmin(address account) internal view returns (bool) {
        return _pauserAdmins.has(account);
    }

    /**
     * @dev Interanl function that adds the given `account` to `_pauserAdmins`.
     * Emits a PauserAdminAdded event.
     *
     * @param account The account address being given access to the pauserAdmin role
     */
    function _addPauserAdmin(address account) internal {
        _pauserAdmins.add(account);
        emit PauserAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_pauserAdmins`.
     * Emits a PauserAdminRemoved event.
     *
     * @param account The account address having access removed from the pauserAdmin role
     */
    function _removePauserAdmin(address account) internal {
        _pauserAdmins.remove(account);
        emit PauserAdminRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_pauserAdmins` with the `newAccount`.
     * Emits a PauserAdminRemoved event.
     * Emits a PauserAdminAdded event.
     *
     * @param previousAccount The account address having access removed from the pauserAdmin role
     * @param newAccount The account address being given access to the pauserAdmin role
     */
    function _replacePauserAdmin(address previousAccount, address newAccount) internal {
        _pauserAdmins.replace(previousAccount, newAccount);
        emit PauserAdminRemoved(previousAccount);
        emit PauserAdminAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_pauserAdmins` with the given array of `accounts`.
     * Emits a PauserAdminAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a PauserAdminRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing pauserAdmins with
     */
    function _replaceAllPauserAdmins(address[] accounts) internal {
        // Emit a PauserAdminAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_pauserAdmins.has(accounts[i])) {
                emit PauserAdminAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _pauserAdmins.replaceAll(accounts);

        // Emit a PauserAdminRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_pauserAdmins.has(previousAccounts[j])) {
                emit PauserAdminRemoved(previousAccounts[j]);
            }
        }
    }
}