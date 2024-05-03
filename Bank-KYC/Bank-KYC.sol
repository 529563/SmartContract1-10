// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// addNewBank
// addNewCustomer
// allowBankToAddCustomer
// allowBankToDoKYC
// blockBankFromAddingCustomer
// blockBankFromDoingKYC
// updateKYCStatus
// viewCustomerData
// viewBankInfo

import "@openzeppelin/contracts/access/Ownable.sol";

// This contract inherits from the OpenZeppelin Ownable contract for ownership management and access control
contract BankKYC is Ownable(msg.sender) {
    // Struct to store bank information
    struct BankInfo {
        string bankName;
        address bankAddress;
        uint256 kycCount;
        bool canAddCustomer;
        bool canDoKYC;
    }

    // Struct to store customer information
    struct CustomerInfo {
        string customerName;
        string customerData;
        address customerBank;
        bool kycStatus;
    }

    // Mapping to store bank information by bank address
    mapping(address => BankInfo) public banks;
    // Mapping to store customer information by customer name
    mapping(string => CustomerInfo) public customers;

    // Events emitted for various actions
    event BankAdded(address indexed bankAddress, string bankName);
    event CustomerAdded(string indexed customerName, address customerBank);
    event KYCStatusUpdated(string indexed customerName, bool kycStatus);

    // Modifier to ensure that the provided bank address is valid (exists in the banks mapping)
    modifier onlyValidBank(address _bankAddress) {
        require(
            banks[_bankAddress].bankAddress != address(0),
            "Invalid bank address"
        );
        _;
    }

    // Function to add a new bank, can only be called by the contract owner
    function addNewBank(
        string memory _bankName,
        address _bankAddress
    ) public onlyOwner {
        require(_bankAddress != address(0), "Invalid bank address");
        require(
            banks[_bankAddress].bankAddress == address(0),
            "Bank already exists"
        );

        banks[_bankAddress] = BankInfo(_bankName, _bankAddress, 0, true, true);
        emit BankAdded(_bankAddress, _bankName);
    }

    // Function to add a new customer, can only be called by a valid bank that is allowed to add customers
    function addNewCustomer(
        string memory _customerName,
        string memory _customerData
    ) public onlyValidBank(msg.sender) {
        require(
            banks[msg.sender].canAddCustomer,
            "Bank is not allowed to add customers"
        );
        require(
            customers[_customerName].customerBank == address(0),
            "Customer already exists"
        );

        customers[_customerName] = CustomerInfo(
            _customerName,
            _customerData,
            msg.sender,
            false
        );
        emit CustomerAdded(_customerName, msg.sender);
    }

    // Function to block a bank from adding customers, can only be called by the contract owner
    function blockBankFromAddingCustomer(
        address _bankAddress
    ) public onlyOwner onlyValidBank(_bankAddress) {
        banks[_bankAddress].canAddCustomer = false;
    }

    // Function to block a bank from performing KYC, can only be called by the contract owner
    function blockBankFromDoingKYC(
        address _bankAddress
    ) public onlyOwner onlyValidBank(_bankAddress) {
        banks[_bankAddress].canDoKYC = false;
    }

    // Function to allow a bank to add customers, can only be called by the contract owner
    function allowBankToAddCustomer(
        address _bankAddress
    ) public onlyOwner onlyValidBank(_bankAddress) {
        banks[_bankAddress].canAddCustomer = true;
    }

    // Function to allow a bank to perform KYC, can only be called by the contract owner
    function allowBankToDoKYC(
        address _bankAddress
    ) public onlyOwner onlyValidBank(_bankAddress) {
        banks[_bankAddress].canDoKYC = true;
    }

    // Function to update the KYC status of a customer, can only be called by a valid bank that is allowed to perform KYC
    function updateKYCStatus(
        string memory _customerName
    ) public onlyValidBank(msg.sender) {
        require(
            banks[msg.sender].canDoKYC,
            "Bank is not allowed to perform KYC"
        );
        require(
            customers[_customerName].customerBank == msg.sender,
            "Customer does not belong to this bank"
        );

        customers[_customerName].kycStatus = true;
        banks[msg.sender].kycCount++;
        emit KYCStatusUpdated(_customerName, true);
    }

    // Function to view the customer data and KYC status of a customer
    function viewCustomerData(
        string memory _customerName
    ) public view returns (string memory, bool) {
        return (
            customers[_customerName].customerData,
            customers[_customerName].kycStatus
        );
    }

    // Function to view the information of a bank, can only be called with a valid bank address
    function viewBankInfo(
        address _bankAddress
    )
        public
        view
        onlyValidBank(_bankAddress)
        returns (string memory, bool, bool, uint256)
    {
        BankInfo memory bank = banks[_bankAddress];
        return (
            bank.bankName,
            bank.canAddCustomer,
            bank.canDoKYC,
            bank.kycCount
        );
    }
}
