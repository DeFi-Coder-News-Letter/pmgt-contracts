pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 *
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    /** Event emitted whenever tokens are transferred from one account to another. */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /** Event emitted whenever an account approves another account to spent from its balance. */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
