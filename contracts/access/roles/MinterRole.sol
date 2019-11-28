pragma solidity ^0.4.24;

import "../Roles.sol";
import "./MinterAdminRole.sol";

/**
 * @title MinterRole
 *
 * @dev Role for providing access control to functions that mint tokens.
 * This contract inherits from MinterAdminRole so that minterAdmins can administer this role.
 */
contract MinterRole is MinterAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the minter role. */
    event MinterAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the minter role. */
    event MinterRemoved(address indexed account);

    /** Mapping of account addresses with access to the minter role. */
    Roles.Role private _minters;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the minter role.
     */
    modifier onlyMinter() {
        require(_isMinter(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the minter role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the minter role, otherwise false
     */
    function isMinter(address account) external view returns (bool) {
        return _isMinter(account);
    }

    /**
     * @return The number of account addresses with access to the minter role.
     */
    function numberOfMinters() external view returns (uint256) {
        return _minters.size();
    }

    /**
     * @return An array containing all account addresses with access to the minter role.
     */
    function minters() external view returns (address[]) {
        return _minters.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the minter role.
     * Callable by an account with the minterAdmin role.
     *
     * @param account The account address being given access to the minter role
     */
    function addMinter(address account) external onlyMinterAdmin {
        _addMinter(account);
    }

    /**
     * @dev Remove access to the minter role for the given `account`.
     * Callable by an account with the minterAdmin role.
     *
     * @param account The account address having access removed from the minter role
     */
    function removeMinter(address account) external onlyMinterAdmin {
        _removeMinter(account);
    }

    /**
     * @dev Remove access to the minter role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the minterAdmin role.
     *
     * @param previousAccount The account address having access removed from the minter role
     * @param newAccount The account address being given access to the minter role
     */
    function replaceMinter(address previousAccount, address newAccount) external onlyMinterAdmin {
        _replaceMinter(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the minter role with the given array of `accounts`.
     * Callable by an account with the minterAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing minters with
     */
    function replaceAllMinters(address[] accounts) external onlyMinterAdmin {
        _replaceAllMinters(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_minters`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_minters`, otherwise false
     */
    function _isMinter(address account) internal view returns (bool) {
        return _minters.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_minters`.
     * Emits a MinterAdded event.
     *
     * @param account The account address being given access to the minter role
     */
    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_minters`.
     * Emits a MinterRemoved event.
     *
     * @param account The account address having access removed from the minter role
     */
    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_minters` with the `newAccount`.
     * Emits a MinterRemoved event.
     * Emits a MinterAdded event.
     *
     * @param previousAccount The account address having access removed from the minter role
     * @param newAccount The account address being given access to the minter role
     */
    function _replaceMinter(address previousAccount, address newAccount) internal {
        _minters.replace(previousAccount, newAccount);
        emit MinterRemoved(previousAccount);
        emit MinterAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_minters` with the given array of `accounts`.
     * Emits a MinterAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a MinterRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing minters with
     */
    function _replaceAllMinters(address[] accounts) internal {
        // Emit a MinterAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_minters.has(accounts[i])) {
                emit MinterAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _minters.replaceAll(accounts);

        // Emit a MinterRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_minters.has(previousAccounts[j])) {
                emit MinterRemoved(previousAccounts[j]);
            }
        }
    }
}