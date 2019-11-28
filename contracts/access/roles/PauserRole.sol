pragma solidity ^0.4.24;

import "../Roles.sol";
import "./PauserAdminRole.sol";

/**
 * @title PauserRole
 *
 * @dev Role for providing access control to functions that pause contract functionality.
 * This contract inherits from PauserAdminRole so that pauserAdmins can administer this role.
 */
contract PauserRole is PauserAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the pauser role. */
    event PauserAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the pauser role. */
    event PauserRemoved(address indexed account);

    /** Mapping of account addresses with access to the pauser role. */
    Roles.Role private _pausers;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the pauser role.
     */
    modifier onlyPauser() {
        require(_isPauser(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the pauser role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the pauser role, otherwise false
     */
    function isPauser(address account) external view returns (bool) {
        return _isPauser(account);
    }

    /**
     * @return The number of account addresses with access to the pauser role.
     */
    function numberOfPausers() external view returns (uint256) {
        return _pausers.size();
    }

    /**
     * @return An array containing all account addresses with access to the pauser role.
     */
    function pausers() external view returns (address[]) {
        return _pausers.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the pauser role.
     * Callable by an account with the pauserAdmin role.
     *
     * @param account The account address being given access to the pauser role
     */
    function addPauser(address account) external onlyPauserAdmin {
        _addPauser(account);
    }

    /**
     * @dev Remove access to the pauser role for the given `account`.
     * Callable by an account with the pauserAdmin role.
     *
     * @param account The account address having access removed from the pauser role
     */
    function removePauser(address account) external onlyPauserAdmin {
        _removePauser(account);
    }

    /**
     * @dev Remove access to the pauser role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the pauserAdmin role.
     *
     * @param previousAccount The account address having access removed from the pauser role
     * @param newAccount The account address being given access to the pauser role
     */
    function replacePauser(address previousAccount, address newAccount) external onlyPauserAdmin {
        _replacePauser(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the pauser role with the given array of `accounts`.
     * Callable by an account with the pauserAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing pausers with
     */
    function replaceAllPausers(address[] accounts) external onlyPauserAdmin {
        _replaceAllPausers(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_pausers`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_pausers`, otherwise false
     */
    function _isPauser(address account) internal view returns (bool) {
        return _pausers.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_pausers`.
     * Emits a PauserAdded event.
     *
     * @param account The account address being given access to the pauser role
     */
    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_pausers`.
     * Emits a PauserRemoved event.
     *
     * @param account The account address having access removed from the pauser role
     */
    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_pausers` with the `newAccount`.
     * Emits a PauserRemoved event.
     * Emits a PauserAdded event.
     *
     * @param previousAccount The account address having access removed from the pauser role
     * @param newAccount The account address being given access to the pauser role
     */
    function _replacePauser(address previousAccount, address newAccount) internal {
        _pausers.replace(previousAccount, newAccount);
        emit PauserRemoved(previousAccount);
        emit PauserAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_pausers` with the given array of `accounts`.
     * Emits a PauserAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a PauserRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing pausers with
     */
    function _replaceAllPausers(address[] accounts) internal {
        // Emit a PauserAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_pausers.has(accounts[i])) {
                emit PauserAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _pausers.replaceAll(accounts);

        // Emit a PauserRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_pausers.has(previousAccounts[j])) {
                emit PauserRemoved(previousAccounts[j]);
            }
        }
    }
}