pragma solidity ^0.4.24;

import "../Roles.sol";

/**
 * @title OwnerRole
 *
 * @dev Role for providing access control to high risk functions, such as upgrades and administering admin roles.
 * All other role contracts should inherit from this contract, as it provides top-level access control.
 */
contract OwnerRole {
    using Roles for Roles.Role;

    //** Event emitted whenever an account is given access to the owner role. */
    event OwnerAdded(address indexed account);

    /** Event emitted whenever an account has access removed from the owner role. */
    event OwnerRemoved(address indexed account);

    /** Mapping of account addresses with access to the owner role. */
    Roles.Role private _owners;

    /**
     * @dev Modifier to make a function callable only when the caller has access to the owner role.
     */
    modifier onlyOwner() {
        require(_isOwner(msg.sender));
        _;
    }

    /**
     * @dev Assert if the given `account` has been provided access to the owner role.
     *
     * @param account The account address being queried
     * @return True if the given `account` has access to the owner role, otherwise false
     */
    function isOwner(address account) external view returns (bool) {
        return _isOwner(account);
    }

    /**
     * @return The number of account addresses with access to the owner role.
     */
    function numberOfOwners() external view returns (uint256) {
        return _owners.size();
    }

    /**
     * @return An array containing all account addresses with access to the owner role.
     */
    function owners() external view returns (address[]) {
        return _owners.toArray();
    }

    /**
     * @dev Provide the given `account` with access to the owner role.
     * Callable by another account with access to the owner role.
     *
     * @param account The account address being given access to the owner role
     */
    function addOwner(address account) external onlyOwner {
        _addOwner(account);
    }

    /**
     * @dev Remove access to the owner role for the given `account`.
     * Callable by another account with access to the owner role.
     *
     * @param account The account address having access removed for the owner role
     */
    function removeOwner(address account) external onlyOwner {
        require(account != msg.sender);
        _removeOwner(account);
    }

    /**
     * @dev Internal function that asserts the given `account` is in `_owners`.
     *
     * @param account The account address being queried
     * @return True if the given `account` is in `_owners`, otherwise false
     */
    function _isOwner(address account) internal view returns (bool) {
        return _owners.has(account);
    }

    /**
     * @dev Internal function that adds the given `account` to the private mapping of `_owners`.
     * Emits an OwnerAdded event.
     *
     * @param account The account account being given access to the owner role
     */
    function _addOwner(address account) internal {
        _owners.add(account);
        emit OwnerAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the private mapping of `_owners`.
     * Emits an OwnerRemoved event.
     *
     * @param account The account account having access removed for the owner role
     */
    function _removeOwner(address account) internal {
        _owners.remove(account);
        emit OwnerRemoved(account);
    }
}