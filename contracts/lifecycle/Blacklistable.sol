pragma solidity ^0.4.24;

import "../access/roles/OwnerRole.sol";
import "../storage/AddressList.sol";
import "../utils/Address.sol";

/**
 * @title Blacklistable
 *
 * @dev Base contract which allows children to restrict functions based on whether an account is on a blacklist.
 * This contract inherits the OwnerRole contract to use RBAC for updating the blacklist reference.
 * This contract references an external AddressList contract that stores the mapping of blacklisted accounts.
 */
contract Blacklistable is OwnerRole {
    /** External AddressList contract storing account addresses that are blacklisted. */
    AddressList private _blacklist;

    /** Event emitted whenever the address of the AddressList contract is updated. */
    event BlacklistUpdated(address indexed previousBlacklist, address indexed newBlacklist);

    /**
     * @dev Modifier to make a function callable only when the given `account` is NOT blacklisted.
     *
     * @param account The account address to check
     */
    modifier notBlacklisted(address account) {
        require(!_blacklist.onList(account));
        _;
    }

    /**
     * @return The address of the `_blacklist` contract
     */
    function blacklist() external view returns (address) {
        return address(_blacklist);
    }

    /**
     * @dev Assert if the given `account` is the address of the current blacklist contract.
     *
     * @param account The address being queried
     * @return True if the given `account` is the address of the current blacklist contract, otherwise false
     */
    function isBlacklist(address account) external view returns (bool) {
        return address(_blacklist) == account;
    }

    /**
     * @dev Asserts if the given `account` is blacklisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is blacklisted, otherwise false
     */
    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist.onList(account);
    }

    /**
     * @dev Update the `_blacklist` to a new contract address.
     * Callable by an account with the owner role.
     *
     * @param newBlacklist The address of the new blacklist contract
     */
    function updateBlacklist(address newBlacklist) external onlyOwner {
        _updateBlacklist(newBlacklist);
    }

    /**
     * @dev Internal function that updates the `_blacklist` to a new contract address.
     * Emits a BlacklistUpdated event.
     *
     * @param newBlacklist The address of the new blacklist contract
     */
    function _updateBlacklist(address newBlacklist) internal {
        require(newBlacklist != address(0));
        require(Address.isContract(newBlacklist));
        emit BlacklistUpdated(address(_blacklist), newBlacklist);
        _blacklist = AddressList(newBlacklist);
    }
}