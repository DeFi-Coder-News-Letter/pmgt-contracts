pragma solidity ^0.4.24;

/**
 * @title Roles
 *
 * @dev Library for managing addresses assigned to a Role, using an internal linked list structure instead of a mapping.
 */
library Roles {
    /** Struct representing a node in the linked list. */
    struct Node {
        // Reference to the previous linked node in the list
        address previous;

        // Whether or not this node (address) has been used before, used to avoid duplicating addresses in the list
        bool hasBeenUsed;

        // Whether or not the node is active (removed nodes become inactive to avoid updating links)
        bool active;
    }

    /** The role struct is essentially the linked list, holding a reference to the head and a mapping of all nodes. */
    struct Role {
        mapping (address => Node) bearer;
        address head;
    }

    /**
     * @return The number of accounts with access to this role
     */
    function size(Role storage role) internal view returns (uint256) {
        uint256 result = 0;

        // Iterate through the linked list mapping and increment for all active nodes
        address current = role.head;
        while (current != address(0)) {
            if (role.bearer[current].active) {
                result++;
            }
            current = role.bearer[current].previous;
        }

        return result;
    }

    /**
     * @return An array containing accounts with access to this role
     */
    function toArray(Role storage role) internal view returns (address[]) {
        // Calculate the number of active nodes (accounts that currently have access to the role)
        uint256 numAccounts = size(role);

        // Instantiate an in-memory array with the calculated size
        address[] memory result = new address[](numAccounts);

        // Iterate through the linked list mapping and increment for all active nodes
        uint256 currentIndex = 0;
        address current = role.head;
        while (current != address(0)) {
            // Add each active node to the result and increment the index for writing the next result
            if (role.bearer[current].active) {
                result[currentIndex] = current;
                currentIndex++;
            }
            current = role.bearer[current].previous;
        }

        return result;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account));

        // If the account has previously existed as a node reactivate it, otherwise add a new node
        if (role.bearer[account].hasBeenUsed) {
            // Node has previously existed, simply set active to true (active node)
            role.bearer[account].active = true;
        } else {
            // Node has not previously existed, create a new node and add it to the head of the linked list
            role.bearer[account].previous = role.head;
            role.bearer[account].hasBeenUsed = true;
            role.bearer[account].active = true;
            role.head = account;
        }
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account));

        // We keep the link to the previous address but set the node to inactive (active == false)
        role.bearer[account].active = false;
    }

    /**
     * @dev Replace an account's access to this role by giving a new account access instead.
     */
    function replace(Role storage role, address previousAccount, address newAccount) internal {
        require(previousAccount != newAccount);
        remove(role, previousAccount);
        add(role, newAccount);
    }

    /**
     * @dev Replace all accounts with access to this role with a new array of accounts.
     * All accounts removed from the role are returned so the caller can emit removal events.
     * No assertions are made against the existing accounts and new accounts, so an account could be removed and added
     * in a single transaction.
     *
     * @param accounts The new array of accounts being given access to this role
     * @return An array containing all account addresses that previously had access to the role
     */
    function replaceAll(Role storage role, address[] accounts) internal returns (address[]) {
        // Reset to the initial state
        address[] memory previousAccounts = reset(role);

        // Add all of the given accounts
        for (uint256 i = 0; i < accounts.length; i++) {
            add(role, accounts[i]);
        }

        return previousAccounts;
    }

    /**
     * @dev Reset the role storage back to its initial (zero) state.
     * All accounts removed from the role are returned so the caller can emit removal events.
     *
     * @return An array containing all account addresses that previously had access to the role
     */
    function reset(Role storage role) internal returns (address[]) {
        // Static array for holding addresses that had access to the role before the reset
        address[] memory removedAccounts = new address[](size(role));

        // Iterate through the linked list mapping and delete all of the nodes
        address currentAddress = role.head;
        uint256 currentIndex = 0;
        while (currentAddress != address(0)) {
            if (role.bearer[currentAddress].active) {
                removedAccounts[currentIndex] = currentAddress;
                currentIndex++;
            }
            address previous = role.bearer[currentAddress].previous;
            delete role.bearer[currentAddress];
            currentAddress = previous;
        }

        // Delete the reference to the head
        delete role.head;

        // Return the removed accounts so the caller can emit removal events
        return removedAccounts;
    }

    /**
     * @dev Assert if an account has this role.
     *
     * @return True if the given `account` has access to this role, otherwise false
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account].active;
    }
}