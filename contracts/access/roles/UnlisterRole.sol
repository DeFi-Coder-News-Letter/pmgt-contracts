pragma solidity ^0.4.24;

import "../Roles.sol";
import "./ListerAdminRole.sol";

/**
 * @title UnlisterRole
 *
 * @dev Role for providing access control to functions that add/remove accounts to/from a blacklist.
 * This contract inherits from ListerAdminRole so that listerAdmins can administer this role.
 */
contract UnlisterRole is ListerAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the unlister role. */
    event UnlisterAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the unlister role. */
    event UnlisterRemoved(address indexed account);

    /** Mapping of account addresses with access to the unlister role. */
    Roles.Role private _unlisters;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the unlister role.
     */
    modifier onlyUnlister() {
        require(_isUnlister(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the unlister role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the unlister role, otherwise false
     */
    function isUnlister(address account) external view returns (bool) {
        return _isUnlister(account);
    }

    /**
     * @return The number of account addresses with access to the unlister role.
     */
    function numberOfUnlisters() external view returns (uint256) {
        return _unlisters.size();
    }

    /**
     * @return An array containing all account addresses with access to the unlister role.
     */
    function unlisters() external view returns (address[]) {
        return _unlisters.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the unlister role.
     * Callable by an account with the listerAdmin role.
     *
     * @param account The account address being given access to the unlister role
     */
    function addUnlister(address account) external onlyListerAdmin {
        _addUnlister(account);
    }

    /**
     * @dev Remove access to the unlister role for the given `account`.
     * Callable by an account with the listerAdmin role.
     *
     * @param account The account address having access removed from the unlister role
     */
    function removeUnlister(address account) external onlyListerAdmin {
        _removeUnlister(account);
    }

    /**
     * @dev Remove access to the unlister role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the unlisterAdmin role.
     *
     * @param previousAccount The account address having access removed from the unlister role
     * @param newAccount The account address being given access to the unlister role
     */
    function replaceUnlister(address previousAccount, address newAccount) external onlyListerAdmin {
        _replaceUnlister(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the unlister role with the given array of `accounts`.
     * Callable by an account with the unlisterAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing unlisters with
     */
    function replaceAllUnlisters(address[] accounts) external onlyListerAdmin {
        _replaceAllUnlisters(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_unlisters`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_unlisters`, otherwise false
     */
    function _isUnlister(address account) internal view returns (bool) {
        return _unlisters.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_unlisters`.
     * Emits a UnlisterAdded event.
     *
     * @param account The account address being given access to the unlister role
     */
    function _addUnlister(address account) internal {
        _unlisters.add(account);
        emit UnlisterAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_unlisters`.
     * Emits a UnlisterRemoved event.
     *
     * @param account The account address having access removed from the unlister role
     */
    function _removeUnlister(address account) internal {
        _unlisters.remove(account);
        emit UnlisterRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_unlisters` with the `newAccount`.
     * Emits a UnlisterRemoved event.
     * Emits a UnlisterAdded event.
     *
     * @param previousAccount The account address having access removed from the unlister role
     * @param newAccount The account address being given access to the unlister role
     */
    function _replaceUnlister(address previousAccount, address newAccount) internal {
        _unlisters.replace(previousAccount, newAccount);
        emit UnlisterRemoved(previousAccount);
        emit UnlisterAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_unlisters` with the given array of `accounts`.
     * Emits a UnlisterAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a UnlisterRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing unlisters with
     */
    function _replaceAllUnlisters(address[] accounts) internal {
        // Emit a UnlisterAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_unlisters.has(accounts[i])) {
                emit UnlisterAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _unlisters.replaceAll(accounts);

        // Emit a UnlisterRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_unlisters.has(previousAccounts[j])) {
                emit UnlisterRemoved(previousAccounts[j]);
            }
        }
    }
}