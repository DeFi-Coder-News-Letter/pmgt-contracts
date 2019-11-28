pragma solidity ^0.4.24;

import "../Roles.sol";
import "./OwnerRole.sol";

/**
 * @title MinterAdminRole
 *
 * @dev Role for providing access control to functions that administer individual minter roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The MinterRole contract should inherit from this contract.
 */
contract MinterAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the minterAdmin role. */
    event MinterAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the minterAdmin role. */
    event MinterAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the minterAdmin role. */
    Roles.Role private _minterAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the minterAdmin role.
     */
    modifier onlyMinterAdmin() {
        require(_isMinterAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the minterAdmin role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the minterAdmin role, otherwise false
     */
    function isMinterAdmin(address account) external view returns (bool) {
        return _isMinterAdmin(account);
    }

    /**
     * @return The number of account addresses with access to the minterAdmin role.
     */
    function numberOfMinterAdmins() external view returns (uint256) {
        return _minterAdmins.size();
    }

    /**
     * @return An array containing all account addresses with access to the minterAdmin role.
     */
    function minterAdmins() external view returns (address[]) {
        return _minterAdmins.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the minterAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the minterAdmin role
     */
    function addMinterAdmin(address account) external onlyOwner {
        _addMinterAdmin(account);
    }

    /**
     * @dev Remove access to the minterAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the minterAdmin role
     */
    function removeMinterAdmin(address account) external onlyOwner {
        _removeMinterAdmin(account);
    }

    /**
     * @dev Remove access to the minterAdmin role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the owner role.
     *
     * @param previousAccount The account address having access removed from the minterAdmin role
     * @param newAccount The account address being given access to the minterAdmin role
     */
    function replaceMinterAdmin(address previousAccount, address newAccount) external onlyOwner {
        _replaceMinterAdmin(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the minterAdmin role with the given array of `accounts`.
     * Callable by an account with the owner role.
     *
     * @param accounts An array of account addresses to replace all existing minterAdmins with
     */
    function replaceAllMinterAdmins(address[] accounts) external onlyOwner {
        _replaceAllMinterAdmins(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_minterAdmins`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_minterAdmins`, otherwise false
     */
    function _isMinterAdmin(address account) internal view returns (bool) {
        return _minterAdmins.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_minterAdmins`.
     * Emits a MinterAdminAdded event.
     *
     * @param account The account address being given access to the minterAdmin role
     */
    function _addMinterAdmin(address account) internal {
        _minterAdmins.add(account);
        emit MinterAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_minterAdmins`.
     * Emits a MinterAdminRemoved event.
     *
     * @param account The account address having access removed from the minterAdmin role
     */
    function _removeMinterAdmin(address account) internal {
        _minterAdmins.remove(account);
        emit MinterAdminRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_minterAdmins` with the `newAccount`.
     * Emits a MinterAdminRemoved event.
     * Emits a MinterAdminAdded event.
     *
     * @param previousAccount The account address having access removed from the minterAdmin role
     * @param newAccount The account address being given access to the minterAdmin role
     */
    function _replaceMinterAdmin(address previousAccount, address newAccount) internal {
        _minterAdmins.replace(previousAccount, newAccount);
        emit MinterAdminRemoved(previousAccount);
        emit MinterAdminAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_minterAdmins` with the given array of `accounts`.
     * Emits a MinterAdminAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a MinterAdminRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing minterAdmins with
     */
    function _replaceAllMinterAdmins(address[] accounts) internal {
        // Emit a MinterAdminAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_minterAdmins.has(accounts[i])) {
                emit MinterAdminAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _minterAdmins.replaceAll(accounts);

        // Emit a MinterAdminRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_minterAdmins.has(previousAccounts[j])) {
                emit MinterAdminRemoved(previousAccounts[j]);
            }
        }
    }
}