// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Ether Wallet
// - Should accept Ether
// - Owner will be able to withdraw

contract EtherWallet {
    // address of the owner set at the deployment of the contract
    address payable public owner;

    // event for withdrawal and deposit
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor() {
        owner = payable(msg.sender); // payable is used to indicate that this address must be paid
    }

    // to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // to fetch the balance of the wallet (this contract)
    function getBalance() external view returns (uint256 balance) {
        return address(this).balance;
    }

    // to withdraw the requested amount (only owner)
    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable {}

    // Tip: The underscore (_) is a special character used in function modifiers.
    // It indicates where the modified function's code should be executed.
    // If the underscore is at the beginning, the modified function's code is executed first, and then the modifier's code.
    // If the underscore is at the end, the modifier's code is executed first, and then the modified function's code.
}
