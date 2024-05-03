// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFund {
    address public projectCreator;
    uint public goalAmount;
    uint public deadline;

    mapping(address => uint) public contributions;
    uint public totalContributions;
    bool public fundingComplete;

    // Events to emit status changes
    event GoalReached(uint totalContributions);
    event FundTransfer(address backer, uint amount);

    constructor(uint _goalAmount, uint _durationInDays) {
        projectCreator = msg.sender;
        goalAmount = _goalAmount * 1 ether; // Convert to wei (1 ether = 1e18 wei)
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    modifier onlyProjectCreator() {
        require(
            msg.sender == projectCreator,
            "Only the project creator can perform this action."
        );
        _;
    }
    modifier goalNotReached() {
        require(
            !fundingComplete && block.timestamp < deadline,
            "Goal already reached or deadline passed."
        );
        _;
    }

    function contribute() external payable goalNotReached {
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        if (totalContributions >= goalAmount) {
            fundingComplete = true;
            emit GoalReached(totalContributions);
        }
        emit FundTransfer(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyProjectCreator {
        require(fundingComplete, "Funding goal not reached yet.");
        payable(projectCreator).transfer(address(this).balance);
    }

    function refundContribution() external goalNotReached {
        require(
            contributions[msg.sender] > 0,
            "You have not contributed to the crowd fund."
        );
        uint amountToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributions -= amountToRefund;
        payable(msg.sender).transfer(amountToRefund);
    }

    function getRemainingTime() external view returns (uint) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }
}
