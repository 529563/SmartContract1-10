// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PiggyBank {
    address public owner;

    event Deposit(uint amount);
    event Withdraw(uint amount);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    receive() external payable {
        emit Deposit(msg.value);
    }

    fallback() external payable {}

    function withdraw(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");

        // Checks-Effects-Interactions pattern
        uint256 balanceBefore = address(this).balance;
        payable(owner).transfer(amount);
        uint256 balanceAfter = address(this).balance;

        require(balanceBefore - balanceAfter == amount, "Transfer failed");

        emit Withdraw(amount);

        // Consider alternative designs to avoid selfdestruct
        // selfdestruct(payable(owner));
    }

    function getBalance() external view returns (uint256 balance) {
        return address(this).balance;
    }
}
