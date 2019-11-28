pragma solidity ^0.4.24;

import "../access/roles/OwnerRole.sol";
import "../storage/AddressList.sol";
import "../utils/Address.sol";

/**
 * @title Whitelistable
 *
 * @dev Base contract which allows children to restrict functions based on whether an account is on a whitelist.
 * This contract inherits the OwnerRole contract to use RBAC for updating the whitelist reference.
 * This contract references an external AddressList contract that stores the mapping of whitelisted accounts.
 */
contract Whitelistable is OwnerRole {
    /** External AddressList contract storing account addresses that are whitelisted. */
    AddressList private _whitelist;

    /** Event emitted whenever the address of the AddressList contract is updated. */
    event WhitelistUpdated(address indexed previousWhitelist, address indexed newWhitelist);

    /**
     * @return The address of the `_whitelist` contract
     */
    function whitelist() external view returns (address) {
        return address(_whitelist);
    }

    /**
     * @dev Assert if the given `account` is the address of the current whitelist contract.
     *
     * @param account The address being queried
     * @return True if the given `account` is the address of the current whitelist contract, otherwise false
     */
    function isWhitelist(address account) external view returns (bool) {
        return address(_whitelist) == account;
    }

    /**
     * @dev Assert if the given `account` is whitelisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is whitelisted, otherwise false
     */
    function isWhitelisted(address account) external view returns (bool) {
        return _whitelist.onList(account);
    }

    /**
     * @dev Update the `_whitelist` to a new contract address.
     * Callable by an account with the owner role.
     *
     * @param newWhitelist The address of the new whitelist contract
     */
    function updateWhitelist(address newWhitelist) external onlyOwner {
        _updateWhitelist(newWhitelist);
    }

    /**
     * @dev Internal function that asserts if the given `account` is whitelisted.
     *
     * @param account The account address to check
     * @return True if the given `account` is whitelisted, otherwise false
     */
    function _isWhitelisted(address account) internal view returns (bool) {
        return _whitelist.onList(account);
    }

    /**
     * @dev Internal function that updates the `_whitelist` to a new contract address.
     * Emits a WhitelistUpdated event.
     *
     * @param newWhitelist The address of the new whitelist contract
     */
    function _updateWhitelist(address newWhitelist) internal {
        require(newWhitelist != address(0));
        require(Address.isContract(newWhitelist));
        emit WhitelistUpdated(address(_whitelist), newWhitelist);
        _whitelist = AddressList(newWhitelist);
    }
}