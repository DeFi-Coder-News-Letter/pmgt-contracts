pragma solidity ^0.4.24;

import "../Roles.sol";
import "./MintLimiterAdminRole.sol";

/**
 * @title MintLimiterRole
 *
 * @dev Role for providing access control to functions that mint tokens.
 * This contract inherits from MintLimiterAdminRole so that mintLimiterAdmins can administer this role.
 */
contract MintLimiterRole is MintLimiterAdminRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the mintLimiter role. */
    event MintLimiterAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the mintLimiter role. */
    event MintLimiterRemoved(address indexed account);

    /** Mapping of account addresses with access to the mintLimiter role. */
    Roles.Role private _mintLimiters;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the mintLimiter role.
     */
    modifier onlyMintLimiter() {
        require(_isMintLimiter(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the mintLimiter role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the mintLimiter role, otherwise false
     */
    function isMintLimiter(address account) external view returns (bool) {
        return _isMintLimiter(account);
    }

    /**
     * @return The number of account addresses with access to the mintLimiter role.
     */
    function numberOfMintLimiters() external view returns (uint256) {
        return _mintLimiters.size();
    }

    /**
     * @return An array containing all account addresses with access to the mintLimiter role.
     */
    function mintLimiters() external view returns (address[]) {
        return _mintLimiters.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the mintLimiter role.
     * Callable by an account with the mintLimiterAdmin role.
     *
     * @param account The account address being given access to the mintLimiter role
     */
    function addMintLimiter(address account) external onlyMintLimiterAdmin {
        _addMintLimiter(account);
    }

    /**
     * @dev Remove access to the mintLimiter role for the given `account`.
     * Callable by an account with the mintLimiterAdmin role.
     *
     * @param account The account address having access removed from the mintLimiter role
     */
    function removeMintLimiter(address account) external onlyMintLimiterAdmin {
        _removeMintLimiter(account);
    }

    /**
     * @dev Remove access to the mintLimiter role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the mintLimiterAdmin role.
     *
     * @param previousAccount The account address having access removed from the mintLimiter role
     * @param newAccount The account address being given access to the mintLimiter role
     */
    function replaceMintLimiter(address previousAccount, address newAccount) external onlyMintLimiterAdmin {
        _replaceMintLimiter(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the mintLimiter role with the given array of `accounts`.
     * Callable by an account with the mintLimiterAdmin role.
     *
     * @param accounts An array of account addresses to replace all existing mintLimiters with
     */
    function replaceAllMintLimiters(address[] accounts) external onlyMintLimiterAdmin {
        _replaceAllMintLimiters(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_mintLimiters`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_mintLimiters`, otherwise false
     */
    function _isMintLimiter(address account) internal view returns (bool) {
        return _mintLimiters.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_mintLimiters`.
     * Emits a MintLimiterAdded event.
     *
     * @param account The account address being given access to the mintLimiter role
     */
    function _addMintLimiter(address account) internal {
        _mintLimiters.add(account);
        emit MintLimiterAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_mintLimiters`.
     * Emits a MintLimiterRemoved event.
     *
     * @param account The account address having access removed from the mintLimiter role
     */
    function _removeMintLimiter(address account) internal {
        _mintLimiters.remove(account);
        emit MintLimiterRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_mintLimiters` with the `newAccount`.
     * Emits a MintLimiterRemoved event.
     * Emits a MintLimiterAdded event.
     *
     * @param previousAccount The account address having access removed from the mintLimiter role
     * @param newAccount The account address being given access to the mintLimiter role
     */
    function _replaceMintLimiter(address previousAccount, address newAccount) internal {
        _mintLimiters.replace(previousAccount, newAccount);
        emit MintLimiterRemoved(previousAccount);
        emit MintLimiterAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_mintLimiters` with the given array of `accounts`.
     * Emits a MintLimiterAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a MintLimiterRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing mintLimiters with
     */
    function _replaceAllMintLimiters(address[] accounts) internal {
        // Emit a MintLimiterAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_mintLimiters.has(accounts[i])) {
                emit MintLimiterAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _mintLimiters.replaceAll(accounts);

        // Emit a MintLimiterRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_mintLimiters.has(previousAccounts[j])) {
                emit MintLimiterRemoved(previousAccounts[j]);
            }
        }
    }
}