pragma solidity ^0.4.24;

import "../access/roles/ListerRole.sol";
import "../access/roles/UnlisterRole.sol";

/**
 * @title AddressList
 *
 * @dev Contract for maintaining a list of addresses, e.g. for a blacklist or whitelist.
 * This contract inherits the Lister contract to use RBAC for administering accounts that can add to the list.
 * This contract inherits the Unlister contract to use RBAC for administering accounts that can remove from the list.
 */
contract AddressList is ListerRole, UnlisterRole {
    /** Whether or not this contract has been initialized. */
    bool private _initialized;

    /** Name of this AddressList, used as a display attribute only. */
    string private _name;

    /** Mapping of each address to whether or not they're on the list. */
    mapping (address => bool) private _onList;

    /** Event emitted whenever an address is added to the list. */
    event AddressAdded(address indexed account);

    /** Event emitted whenever an address is removed from the list. */
    event AddressRemoved(address indexed account);

    /**
     * @dev Initialize function used in place of a constructor.
     * This is required over a normal due to the constructor caveat when using proxy contracts.
     *
     * @param name The name of the address list
     */
    function initialize(string name) external {
        // Assert that the contract hasn't already been initialized
        require(!_initialized);

        // Provide the account initializing the contract with access to the owner role
        super._addOwner(msg.sender);

        // Set the name of the list
        _name = name;

        // Set the initialized state to true so the contract cannot be initialized again
        _initialized = true;
    }

    /**
     * @return True if the contract has been initialized, otherwise false
     */
    function initialized() external view returns (bool) {
        return _initialized;
    }

    /**
     * @return The name of the AddressList
     */
    function name() external view returns (string) {
        return _name;
    }

    /**
     * @dev Query whether the the given `account` is on this list or not.
     *
     * @param account The account address being queried
     * @return True if the account is on the list, otherwise false
     */
    function onList(address account) external view returns (bool) {
        return _onList[account];
    }

    /**
     * @dev Update the name of the list.
     * Callable by an account with the listerAdmin role.
     *
     * @param newName The new display name of the list
     */
    function updateName(string newName) external onlyListerAdmin {
        _name = newName;
    }

    /**
     * @dev Add the given `account` to the list.
     * Callable by an account with the lister role.
     *
     * @param account Account to add to the list
     */
    function addAddress(address account) external onlyLister {
        _addAddress(account);
    }

    /**
     * @dev Remove the given `account` from the list.
     * Callable by an account with the unlister role.
     *
     * @param account Account to remove from the list
     */
    function removeAddress(address account) external onlyUnlister {
        _removeAddress(account);
    }

    /**
     * @dev Replace the `previousAccount` in the list with the `newAccount`.
     * Callable by an account with both the lister role and unlister role.
     *
     * @param previousAccount Account to remove from the list
     * @param newAccount Account to add to the list
     */
    function replaceAddress(address previousAccount, address newAccount) external onlyLister onlyUnlister {
        _removeAddress(previousAccount);
        _addAddress(newAccount);
    }

    /**
     * @dev Internal function that adds the given `account` to the `_onList` mapping.
     * Emits an AddressAdded event.
     *
     * @param account The account being added to the list
     */
    function _addAddress(address account) internal {
        // Throw if the account is already on the list
        require(!_onList[account]);

        _onList[account] = true;
        emit AddressAdded(account);
    }

    /**
     * @dev Internal function that removes the given `account` from the `_onList` mapping.
     * Emits an AddressRemoved event.
     *
     * @param account The account being removed from the list
     */
    function _removeAddress(address account) internal {
        // Throw if the account is not on the list
        require(_onList[account]);

        _onList[account] = false;
        emit AddressRemoved(account);
    }
}
