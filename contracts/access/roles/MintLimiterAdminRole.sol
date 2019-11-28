pragma solidity ^0.4.24;

import "../Roles.sol";
import "./OwnerRole.sol";

/**
 * @title MintLimiterAdminRole
 *
 * @dev Role for providing access control to functions that administer individual mint limiter roles.
 * This contract inherits from OwnerRole so that owners can administer this role.
 * The MintLimiterRole contract should inherit from this contract.
 */
contract MintLimiterAdminRole is OwnerRole {
    using Roles for Roles.Role;

    /** Event emitted whenever an account is given access to the mintLimiterAdmin role. */
    event MintLimiterAdminAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the mintLimiterAdmin role. */
    event MintLimiterAdminRemoved(address indexed account);

    /** Mapping of account addresses with access to the mintLimiterAdmin role. */
    Roles.Role private _mintLimiterAdmins;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the mintLimiterAdmin role.
     */
    modifier onlyMintLimiterAdmin() {
        require(_isMintLimiterAdmin(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the mintLimiterAdmin role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the mintLimiterAdmin role, otherwise false
     */
    function isMintLimiterAdmin(address account) external view returns (bool) {
        return _isMintLimiterAdmin(account);
    }

    /**
     * @return The number of account addresses with access to the mintLimiterAdmin role.
     */
    function numberOfMintLimiterAdmins() external view returns (uint256) {
        return _mintLimiterAdmins.size();
    }

    /**
     * @return An array containing all account addresses with access to the mintLimiterAdmin role.
     */
    function mintLimiterAdmins() external view returns (address[]) {
        return _mintLimiterAdmins.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the mintLimiterAdmin role.
     * Callable by an account with the owner role.
     *
     * @param account The account address being given access to the mintLimiterAdmin role
     */
    function addMintLimiterAdmin(address account) external onlyOwner {
        _addMintLimiterAdmin(account);
    }

    /**
     * @dev Remove access to the mintLimiterAdmin role for the given `account`.
     * Callable by an account with the owner role.
     *
     * @param account The account address having access removed from the mintLimiterAdmin role
     */
    function removeMintLimiterAdmin(address account) external onlyOwner {
        _removeMintLimiterAdmin(account);
    }

    /**
     * @dev Remove access to the mintLimiterAdmin role for the `previousAccount` and give access to the `newAccount`.
     * Callable by an account with the owner role.
     *
     * @param previousAccount The account address having access removed from the mintLimiterAdmin role
     * @param newAccount The account address being given access to the mintLimiterAdmin role
     */
    function replaceMintLimiterAdmin(address previousAccount, address newAccount) external onlyOwner {
        _replaceMintLimiterAdmin(previousAccount, newAccount);
    }

    /**
     * @dev Replace all accounts that have access to the mintLimiterAdmin role with the given array of `accounts`.
     * Callable by an account with the owner role.
     *
     * @param accounts An array of account addresses to replace all existing mintLimiterAdmins with
     */
    function replaceAllMintLimiterAdmins(address[] accounts) external onlyOwner {
        _replaceAllMintLimiterAdmins(accounts);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_mintLimiterAdmins`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_mintLimiterAdmins`, otherwise false
     */
    function _isMintLimiterAdmin(address account) internal view returns (bool) {
        return _mintLimiterAdmins.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to `_mintLimiterAdmins`.
     * Emits a MintLimiterAdminAdded event.
     *
     * @param account The account address being given access to the mintLimiterAdmin role
     */
    function _addMintLimiterAdmin(address account) internal {
        _mintLimiterAdmins.add(account);
        emit MintLimiterAdminAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from `_mintLimiterAdmins`.
     * Emits a MintLimiterAdminRemoved event.
     *
     * @param account The account address having access removed from the mintLimiterAdmin role
     */
    function _removeMintLimiterAdmin(address account) internal {
        _mintLimiterAdmins.remove(account);
        emit MintLimiterAdminRemoved(account);
    }

    /**
     * @dev Internal function that replaces the `previousAccount` in `_mintLimiterAdmins` with the `newAccount`.
     * Emits a MintLimiterAdminRemoved event.
     * Emits a MintLimiterAdminAdded event.
     *
     * @param previousAccount The account address having access removed from the mintLimiterAdmin role
     * @param newAccount The account address being given access to the mintLimiterAdmin role
     */
    function _replaceMintLimiterAdmin(address previousAccount, address newAccount) internal {
        _mintLimiterAdmins.replace(previousAccount, newAccount);
        emit MintLimiterAdminRemoved(previousAccount);
        emit MintLimiterAdminAdded(newAccount);
    }

    /**
     * @dev Internal function that replaces all accounts in `_mintLimiterAdmins` with the given array of `accounts`.
     * Emits a MintLimiterAdminAdded event for each account in the `accounts` array that doesn't already have access.
     * Emits a MintLimiterAdminRemoved event for each account that has access removed from the tester role.
     *
     * @param accounts An array of account addresses to replace all existing mintLimiterAdmins with
     */
    function _replaceAllMintLimiterAdmins(address[] accounts) internal {
        // Emit a MintLimiterAdded event for each account that doesn't already have access to the role
        for (uint256 i = 0; i < accounts.length; i++) {
            if (!_mintLimiterAdmins.has(accounts[i])) {
                emit MintLimiterAdminAdded(accounts[i]);
            }
        }

        // Replace all existing accounts with the given array of addresses
        address[] memory previousAccounts = _mintLimiterAdmins.replaceAll(accounts);

        // Emit a MintLimiterRemoved event for each previous account that no longer has access to the role
        for (uint256 j = 0; j < previousAccounts.length; j++) {
            if (!_mintLimiterAdmins.has(previousAccounts[j])) {
                emit MintLimiterAdminRemoved(previousAccounts[j]);
            }
        }
    }
}