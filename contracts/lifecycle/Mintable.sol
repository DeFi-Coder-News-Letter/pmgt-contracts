pragma solidity ^0.4.24;

import "../access/roles/MinterRole.sol";
import "../math/SafeMath.sol";
import "../access/roles/MintLimiterRole.sol";

/**
 * @title Mintable
 *
 * @dev Base contract which allows children to implement limit-based minting of tokens.
 * This contract inherits the MinterRole contract to use RBAC for administering accounts that can mint tokens.
 * This contract inherits the MintLimiterRole contract to use RBAC for administering accounts that limit the minters.
 */
contract Mintable is MinterRole, MintLimiterRole {
    using SafeMath for uint256;

    /** The amount of tokens each minter is allowed to mint. */
    mapping(address => uint256) private _minterLimits;

    /** Mapping of unique mint identifiers to whether or not they've been used before. */
    mapping(int256 => bool) private mintIds;

    /** Event emitted whenever a minter limit is updated. */
    event MinterLimitUpdated(address indexed minter, uint256 limit);

    /** Event emitted whenever tokens are minted. */
    event Mint(address indexed minter, address indexed to, uint256 value, int256 mintId);

    /**
     * @dev Gets the amount of tokens the given `minter` is limited to minting.
     *
     * @param minter The minter account whose limit is being queried
     * @return The amount of tokens allowed to be minted
     */
    function mintLimitOf(address minter) external view returns (uint256) {
        return _minterLimits[minter];
    }

    /**
     * @dev Extension of the MinterRole removeMinter function to additionally set minter limit to zero.
     * Callable by an account with the minterAdmin role.
     *
     * @param account The account address having access removed from the minter role
     */
    function removeMinter(address account) external onlyMinterAdmin {
        _setLimit(account, 0);
        super._removeMinter(account);
    }

    /**
     * @dev Set the amount of tokens the given `minter` is allowed to mint.
     * Callable by an account with the mintLimiter role.
     *
     * @notice This function should only be called when setting the minter's limit to zero.
     *
     * @param minter The minter account whose limit is being set
     * @param value The amount to set the minter's limit to
     */
    function setMintLimit(address minter, uint256 value) external onlyMintLimiter {
        require(super._isMinter(minter));
        _setLimit(minter, value);
    }

    /**
     * @dev Increase the amount of tokens the given `minter` is allowed to mint.
     * Callable by an account with the mintLimiter role.
     *
     * @param minter The minter account whose limit is being increased
     * @param value The amount to increase the minter's limit by
     */
    function increaseMintLimit(address minter, uint256 value) external onlyMintLimiter {
        require(super._isMinter(minter));
        _setLimit(minter, _minterLimits[minter].add(value));
    }

    /**
     * @dev Decrease the amount of tokens the given `_minter` is allowed to mint.
     * Callable by an account with the mintLimiter role.
     *
     * @param minter The minter account whose limit is being decreased
     * @param value The amount to decrease the minter's limit by
     */
    function decreaseMintLimit(address minter, uint256 value) external onlyMintLimiter {
        require(super._isMinter(minter));
        _setLimit(minter, _minterLimits[minter].sub(value));
    }

    /**
     * @dev Internal function that sets the limit of a minter in the private mapping of `_minterLimits`.
     * Emits a MinterLimitUpdated event.
     *
     * @param minter The minter account whose limit is being updated
     * @param limit The amount of tokens to set the minter's limit to
     */
    function _setLimit(address minter, uint256 limit) internal {
        _minterLimits[minter] = limit;
        emit MinterLimitUpdated(minter, limit);
    }

    /**
     * @dev Internal function that should be called whenever new tokens are being minted as it encapsulates limit logic.
     * Emits a Mint event.
     *
     * @param minter The account that is minting the tokens
     * @param to The account the tokens are being minted to
     * @param value The amount of tokens being minted
     * @param mintId A unique identifier for the mint transaction
     */
    function _mint(address minter, address to, uint256 value, int256 mintId) internal {
        // Assert that the to address is not null account and that the value is greater than zero
        require(to != address(0));
        require(value > 0);

        // Assert that the mintId has not been used before
        require(!mintIds[mintId]);

        // Decrease the minter's mint limit by the minted value
        _minterLimits[minter] = _minterLimits[minter].sub(value);

        // Add the mintId to the mapping of used mintIds
        mintIds[mintId] = true;

        // Emit the mint event
        emit Mint(minter, to, value, mintId);
    }
}