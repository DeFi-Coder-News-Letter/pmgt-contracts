pragma solidity ^0.4.24;

import "../Roles.sol";
import "./OwnerRole.sol";

/**
 * @title ListerAdminRole
 *
 * @dev Role for providing access control to functions that administer individual lister roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The ListerRole contract should inherit from this contract.
 */
contract ListerAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the listerAdmin role. */
    event ListerAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the listerAdmin role. */
    event ListerAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the listerAdmin role. */
    Roles.Role private _listerAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the listerAdmin role.
     */
    modifier onlyListerAdmin() {
        require(_isListerAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the listerAdmin role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the listerAdmin role, otherwise false
     */
    function isListerAdmin(address account) external view returns (bool) {
        return _isListerAdmin(account);
    }

    /**
     * @return The number of account addresses with access to the listerAdmin role.
     */
    function numberOfListerAdmins() external view returns (uint256) {
        return _listerAdmins.size();
    }

    /**
     * @return An array containing all account addresses with access to the listerAdmin role.
     */
    function listerAdmins() external view returns (address[]) {
        return _listerAdmins.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the listerAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the listerAdmin role
     */
    function addListerAdmin(address account) external onlyOwner {
        _addListerAdmin(account);
    }

    /**
     * @dev Remove access to the listerAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the listerAdmin role
     */
    function removeListerAdmin(address account) external onlyOwner {
        _removeListerAdmin(account);
    }

    /**
     * @dev Remove access to the listerAdmin role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the owner role.
     *
     * @param previousAccount The account address having access removed from the listerAdmin role
     * @param newAccount The account address being given access to the listerAdmin role
     */
    function replaceListerAdmin(address previousAccount, address newAccount) external onlyOwner {
        _replaceListerAdmin(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the listerAdmin role with the given array of `accounts`.
     * Callable by an account with the owner role.
     *
     * @param accounts An array of account addresses to replace all existing listerAdmins with
     */
    function replaceAllListerAdmins(address[] accounts) external onlyOwner {
        _replaceAllListerAdmins(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_listerAdmins`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_listerAdmins`, otherwise false
     */
    function _isListerAdmin(address account) internal view returns (bool) {
        return _listerAdmins.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_listerAdmins`.
     * Emits a ListerAdminAdded event.
     *
     * @param account The account address being given access to the listerAdmin role
     */
    function _addListerAdmin(address account) internal {
        _listerAdmins.add(account);
        emit ListerAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_listerAdmins`.
     * Emits a ListAdminRemoved event.
     *
     * @param account The account address having access removed from the listerAdmin role
     */
    function _removeListerAdmin(address account) internal {
        _listerAdmins.remove(account);
        emit ListerAdminRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_listerAdmins` with the `newAccount`.
     * Emits a ListerAdminRemoved event.
     * Emits a ListerAdminAdded event.
     *
     * @param previousAccount The account address having access removed from the listerAdmin role
     * @param newAccount The account address being given access to the listerAdmin role
     */
    function _replaceListerAdmin(address previousAccount, address newAccount) internal {
        _listerAdmins.replace(previousAccount, newAccount);
        emit ListerAdminRemoved(previousAccount);
        emit ListerAdminAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_listerAdmins` with the given array of `accounts`.
     * Emits a ListerAdminAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a ListerAdminRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing listerAdmins with
     */
    function _replaceAllListerAdmins(address[] accounts) internal {
        // Emit a ListerAdminAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_listerAdmins.has(accounts[i])) {
                emit ListerAdminAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _listerAdmins.replaceAll(accounts);

        // Emit a ListerAdminRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_listerAdmins.has(previousAccounts[j])) {
                emit ListerAdminRemoved(previousAccounts[j]);
            }
        }
    }
}