pragma solidity ^0.4.24;

import "../access/roles/OwnerRole.sol";
import "../math/SafeMath.sol";

/**
 * @title Burnable
 *
 * @dev Base contract which allows children to implement burning of tokens by transferring to a `_burnAddress`.
 * This contract inherits the OwnerRole contract to use RBAC for updating the `_burnAddress`.
 */
contract Burnable is OwnerRole {
    using SafeMath for uint256;

    /** Transfers made to this address are treated as burns, causing both balance and token supply to decrease. */
    address private _burnAddress;

    /** Event emitted whenever the burn address is updated. */
    event BurnAddressUpdated(address indexed previousBurnAddress, address indexed newBurnAddress);

    /** Event emitted whenever tokens are burned. */
    event Burn(address indexed burner, uint256 value);

    /**
     * @return The `_burnAddress`, for which transfers to are treated as burns
     */
    function burnAddress() external view returns (address) {
        return _burnAddress;
    }

    /**
     * @dev Assert if the given `account` is the burn address.
     *
     * @param account The address being queried
     * @return True if the given `account` is the burn address, otherwise false
     */
    function isBurnAddress(address account) external view returns (bool) {
        return _burnAddress == account;
    }

    /**
     * @dev Update the `_burnAddress` to a new address.
     * Transfers to the `newBurnAddress` will be treated as burns.
     * Callable by an account with the owner role.
     *
     * @param newBurnAddress The new address to set as the burn address
     */
    function updateBurnAddress(address newBurnAddress) external onlyOwner {
        _updateBurnAddress(newBurnAddress);
    }

    /**
     * @dev Internal function that asserts if the given `account` is the burn address.
     *
     * @param account The address being queried
     * @return True if the given `account` is the burn address, otherwise false
     */
    function _isBurnAddress(address account) internal view returns (bool) {
        return _burnAddress == account;
    }

    /**
     * @dev Internal function that updates the `_burnAddress` to a new address.
     * Emits a BurnAddressUpdated event.
     *
     * @param newBurnAddress The new address to set as the burn address
     */
    function _updateBurnAddress(address newBurnAddress) internal {
        require(newBurnAddress != address(0));
        emit BurnAddressUpdated(_burnAddress, newBurnAddress);
        _burnAddress = newBurnAddress;
    }

    /**
     * @dev Internal function that should be called whenever tokens are being burned.
     * Emits a Burn event.
     *
     * @param burner The address of the account burning tokens
     * @param value The amount of tokens being burnt
     */
    function _burn(address burner, uint256 value) internal {
        require(value > 0);
        emit Burn(burner, value);
    }
}