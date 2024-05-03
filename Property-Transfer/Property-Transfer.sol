// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// user can add property
// user can queryPropertyById
// user can list a property for sale and ask the price
// user can transfer ownership of a property
// user can buy a listed property

import "@openzeppelin/contracts/access/Ownable.sol";

// This contract inherits from the OpenZeppelin Ownable contract for ownership management and access control
contract PropertyTransferApp is Ownable(msg.sender) {
    // Struct to represent a property
    struct Property {
        uint256 id;
        string name;
        address owner;
        uint256 value;
        uint256 area;
        bool isForSale; // Flag to indicate if the property is listed for sale
        uint256 askingPrice; // Asking price when the property is listed for sale
    }

    // Mapping to store properties by their IDs
    mapping(uint256 => Property) public properties;
    uint256 public propertyCount; // Total number of properties

    // Events emitted for different property-related activities
    event PropertyAdded(
        uint256 indexed propertyId,
        string name,
        address owner,
        uint256 value,
        uint256 area
    );
    event PropertyOwnershipTransferred(
        uint256 indexed propertyId,
        address newOwner
    );
    event PropertyListedForSale(
        uint256 indexed propertyId,
        uint256 askingPrice
    );
    event PropertySold(
        uint256 indexed propertyId,
        address newOwner,
        uint256 salePrice
    );

    // Modifier to check if a property ID is valid
    modifier propertyExists(uint256 _propertyId) {
        require(_propertyId < propertyCount, "Property does not exist");
        _;
    }

    // Function to add a new property, can only be called by the contract owner
    function addProperty(
        string memory _name,
        uint256 _value,
        uint256 _area
    ) public onlyOwner {
        properties[propertyCount] = Property(
            propertyCount,
            _name,
            msg.sender,
            _value,
            _area,
            false,
            0
        );
        emit PropertyAdded(propertyCount, _name, msg.sender, _value, _area);
        propertyCount++;
    }

    // Function to query a property by its ID
    function queryPropertyById(
        uint256 _propertyId
    )
        public
        view
        propertyExists(_propertyId)
        returns (
            string memory name,
            address owner,
            uint256 area,
            uint256 value,
            bool isForSale,
            uint256 askingPrice
        )
    {
        Property storage property = properties[_propertyId];
        return (
            property.name,
            property.owner,
            property.area,
            property.value,
            property.isForSale,
            property.askingPrice
        );
    }

    // Function to transfer ownership of a property, can only be called by the contract owner
    function transferPropertyOwnership(
        uint256 _propertyId,
        address _newOwner
    ) public onlyOwner propertyExists(_propertyId) {
        properties[_propertyId].owner = _newOwner;
        emit PropertyOwnershipTransferred(_propertyId, _newOwner);
    }

    // Function to list a property for sale, can only be called by the property owner
    function listPropertyForSale(
        uint256 _propertyId,
        uint256 _askingPrice
    ) public propertyExists(_propertyId) {
        require(
            msg.sender == properties[_propertyId].owner,
            "Only the owner can list a property for sale"
        );
        properties[_propertyId].isForSale = true;
        properties[_propertyId].askingPrice = _askingPrice;
        emit PropertyListedForSale(_propertyId, _askingPrice);
    }

    // Function to buy a listed property
    function buyProperty(
        uint256 _propertyId
    ) public payable propertyExists(_propertyId) {
        Property storage property = properties[_propertyId];
        require(property.isForSale, "Property is not for sale");
        require(msg.value >= property.askingPrice, "Insufficient funds sent");

        address payable currentOwner = payable(property.owner);
        currentOwner.transfer(msg.value); // Transfer funds to the current owner

        property.owner = msg.sender; // Transfer ownership to the buyer
        property.isForSale = false;
        property.askingPrice = 0;

        emit PropertySold(_propertyId, msg.sender, msg.value);
    }
}
