// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import the IERC20 interface from OpenZeppelin contracts
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

// Define the SubscriptionPlan contract
contract SubscriptionPlan {
    // Declare the ERC20 token interface
    IERC20 token;
    // Declare the owner of the contract
    address public owner;
    // Declare the merchant's address
    address public merchant;

    // Define the frequency of payments
    uint256 public frequency;
    // Define the amount to be paid
    uint256 public amount;

    // Define a struct for subscription details
    struct Subscription {
        // The address of the subscriber
        address subscriber;
        // The start time of the subscription
        uint start;
        // The timestamp of the next payment
        uint nextPayment;
    }

    // Mapping to store subscription details for each subscriber
    mapping(address => Subscription) public subscriptions;

    // Event to log when a subscription is created
    event SubscriptionCreated(address subscriber, uint date);
    // Event to log when a subscription is cancelled
    event SubscriptionCancelled(address subscriber, uint date);
    // Event to log when a payment is sent
    event PaymentSent(address from, address to, uint amount, uint date);

    // Constructor to initialize the contract
    constructor(
        address _token,
        address _merchant,
        uint _amount,
        uint _frequency
    ) {
        // Initialize the token interface with the provided token address
        token = IERC20(_token);
        // Set the owner of the contract to the deployer
        owner = msg.sender;
        // Ensure the merchant address is not null
        require(_merchant != address(0), "Address cannot be null address");
        merchant = _merchant;
        // Ensure the amount is not zero
        require(_amount != 0, "Amount cannot be zero");
        amount = _amount;
        // Ensure the frequency is not zero
        require(_frequency != 0, "Frequency cannot be zero");
        frequency = _frequency;
    }

    // Function for a user to subscribe
    function subscribe() external {
        // Ensure the user has approved the contract to spend their tokens
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );
        // Transfer the subscription amount from the user to the merchant
        token.transferFrom(msg.sender, merchant, amount);
        // Emit an event for the payment
        emit PaymentSent(msg.sender, merchant, amount, block.timestamp);

        // Create a new subscription for the user
        subscriptions[msg.sender] = Subscription(
            msg.sender,
            block.timestamp,
            block.timestamp + frequency
        );
        // Emit an event for the subscription creation
        emit SubscriptionCreated(msg.sender, block.timestamp);
    }

    // Function for a user to cancel their subscription
    function cancel() external {
        // Retrieve the subscription details for the user
        Subscription storage subscription = subscriptions[msg.sender];
        // Ensure the subscription exists
        require(
            subscription.subscriber != address(0),
            "This subscription does not exist"
        );
        // Delete the subscription for the user
        delete subscriptions[msg.sender];
        // Emit an event for the subscription cancellation
        emit SubscriptionCancelled(msg.sender, block.timestamp);
    }

    // Function to manually trigger a payment for a subscription
    function pay(address subscriber) external {
        // Retrieve the subscription details for the subscriber
        Subscription storage subscription = subscriptions[subscriber];
        // Ensure the subscription exists
        require(
            subscription.subscriber != address(0),
            "This subscription does not exist"
        );
        // Ensure the payment is due
        require(
            block.timestamp >= subscription.nextPayment,
            "Payment not due yet"
        );

        // Transfer the subscription amount from the subscriber to the merchant
        token.transferFrom(subscriber, merchant, amount);
        // Emit an event for the payment
        emit PaymentSent(subscriber, merchant, amount, block.timestamp);

        // Update the next payment timestamp
        subscription.nextPayment += frequency;
    }
}
