pragma solidity ^0.4.24;

import "../Roles.sol";
import "./ListerAdminRole.sol";

/**
 * @title ListerRole
 *
 * @dev Role for providing access control to functions that add/remove accounts to/from a blacklist.
 * This contract inherits from ListerAdminRole so that listerAdmins can administer this role.
 */
contract ListerRole is ListerAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the lister role. */
    event ListerAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the lister role. */
    event ListerRemoved(address indexed account);

    /** Mapping of account addresses with access to the lister role. */
    Roles.Role private _listers;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the lister role.
     */
    modifier onlyLister() {
        require(_isLister(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the lister role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the lister role, otherwise false
     */
    function isLister(address account) external view returns (bool) {
        return _isLister(account);
    }

    /**
     * @return The number of account addresses with access to the lister role.
     */
    function numberOfListers() external view returns (uint256) {
        return _listers.size();
    }

    /**
     * @return An array containing all account addresses with access to the lister role.
     */
    function listers() external view returns (address[]) {
        return _listers.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the lister role.
     * Callable by an account with the listerAdmin role.
     *
     * @param account The account address being given access to the lister role
     */
    function addLister(address account) external onlyListerAdmin {
        _addLister(account);
    }

    /**
     * @dev Remove access to the lister role for the given `account`.
     * Callable by an account with the listerAdmin role.
     *
     * @param account The account address having access removed from the lister role
     */
    function removeLister(address account) external onlyListerAdmin {
        _removeLister(account);
    }

    /**
     * @dev Remove access to the lister role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the listerAdmin role.
     *
     * @param previousAccount The account address having access removed from the lister role
     * @param newAccount The account address being given access to the lister role
     */
    function replaceLister(address previousAccount, address newAccount) external onlyListerAdmin {
        _replaceLister(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the lister role with the given array of `accounts`.
     * Callable by an account with the listerAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing listers with
     */
    function replaceAllListers(address[] accounts) external onlyListerAdmin {
        _replaceAllListers(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_listers`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_listers`, otherwise false
     */
    function _isLister(address account) internal view returns (bool) {
        return _listers.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_listers`.
     * Emits a ListerAdded event.
     *
     * @param account The account address being given access to the listerAdmin role
     */
    function _addLister(address account) internal {
        _listers.add(account);
        emit ListerAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_listers`.
     * Emits a ListerRemoved event.
     *
     * @param account The account address having access removed from the lister role
     */
    function _removeLister(address account) internal {
        _listers.remove(account);
        emit ListerRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_listers` with the `newAccount`.
     * Emits a ListerRemoved event.
     * Emits a ListerAdded event.
     *
     * @param previousAccount The account address having access removed from the lister role
     * @param newAccount The account address being given access to the lister role
     */
    function _replaceLister(address previousAccount, address newAccount) internal {
        _listers.replace(previousAccount, newAccount);
        emit ListerRemoved(previousAccount);
        emit ListerAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_listers` with the given array of `accounts`.
     * Emits a ListerAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a ListerRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing listers with
     */
    function _replaceAllListers(address[] accounts) internal {
        // Emit a ListerAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_listers.has(accounts[i])) {
                emit ListerAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _listers.replaceAll(accounts);

        // Emit a ListerRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_listers.has(previousAccounts[j])) {
                emit ListerRemoved(previousAccounts[j]);
            }
        }
    }
}