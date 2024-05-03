// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Voting {
    struct Association {
        string name; // name of the association
        uint votes; // number of votes received by the association
    }
    Association[] public associations; // array of all associations
    address[] private voters; // list of addresses of voters
    bool public votingOpen; // flag to check if voting is open or closed
    address public owner; // address of the owner of the contract
    string public winner; // name of the association with the most votes

    constructor() {
        owner = msg.sender; // set the owner of the contract as the msg.sender
        votingOpen = true; // set votingOpen flag to true
    }

    // function to add a new association to the contract
    function addAssociation(string memory _name) public {
        // check if an association with the same name already exists
        require(
            !associationExists(_name),
            "Association with this name already exists."
        );
        // create a new association with the given name and 0 votes
        Association memory association = Association(_name, 0);
        // add the new association to the list of associations
        associations.push(association);
    }

    // function to check if an association with the given name already exists
    function associationExists(
        string memory _name
    ) private view returns (bool) {
        // loop through all existing associations
        for (uint i = 0; i < associations.length; i++) {
            // hash the name of the current association and the searched name
            bytes4 hashedString = bytes4(
                keccak256(abi.encodePacked(associations[i].name))
            );
            bytes4 hashedSearchString = bytes4(
                keccak256(abi.encodePacked(_name))
            );
            // check if the hashed name of the current association matches the hashed searched name
            if (hashedString == hashedSearchString) {
                return true; // association with the same name already exists
            }
        }
        return false; // association with the given name does not exist
    }

    function vote(uint _index) public {
        // Check if voting is open. If not, throw error message
        require(votingOpen, "Voting is closed.");
        // Check if the selected association index is within the range of the associations array. If not, throw error message.
        require(_index < associations.length, "Invalid association selected.");
        // Check if the voter has already voted. If so, throw error message.
        require(!voterExists(), "You have already voted.");
        // Add the voter's address to the voters array
        voters.push(msg.sender);
        // Increase the vote count for the selected association
        associations[_index].votes++;
    }

    function voterExists() private view returns (bool) {
        // Iterate through the voters array to check if the voter has already voted
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == msg.sender) {
                return true;
            }
        }
        // If the voter's address is not found in the voters array, return false
        return false;
    }

    function getTotalVotes() public view returns (uint) {
        // variable to store the total number of votes
        uint countVotes = 0;
        // loop through all the associations and add their number of votes to the countVotes variable
        for (uint i = 0; i < associations.length; i++) {
            countVotes += associations[i].votes;
        }
        // return the total number of votes
        return countVotes;
    }

    function endVoting() public {
        // Check if the msg.sender is the owner of the contract
        require(owner == msg.sender, "Only the owner can close the voting.");
        // Check if voting is open
        require(votingOpen, "Voting is already closed.");
        // Set votingOpen flag to false
        votingOpen = false;
        // Get the winner of the voting
        winner = getWinner();
    }

    function getWinner() private view returns (string memory) {
        // Initialize variables to store the max votes and index of the association with max votes
        uint maxVotes = 0;
        uint maxIndex;
        // Iterate through all the associations
        for (uint i = 0; i < associations.length; i++) {
            // Check if the current association has more votes than the previous max
            if (associations[i].votes > maxVotes) {
                // Update maxVotes and maxIndex
                maxVotes = associations[i].votes;
                maxIndex = i;
            }
        }
        // Return the name of the association with the most votes
        return associations[maxIndex].name;
    }
}
