// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CollegeIDTracker is Ownable(msg.sender) {
    struct Student {
        string name;
        uint256 idNumber;
        bool isEnrolled;
        uint256 enrollmentYear;
        string department;
    }

    mapping(uint256 => Student) public students;
    mapping(address => mapping(uint256 => bool)) public studentApprovals;
    uint256 public studentCount;

    event StudentEnrolled(
        uint256 idNumber,
        string name,
        uint256 enrollmentYear,
        string department
    );
    event StudentUnenrolled(uint256 idNumber, string name);
    event StudentDataUpdated(
        uint256 idNumber,
        string name,
        uint256 enrollmentYear,
        string department
    );

    modifier onlyApprovedStudent(uint256 _idNumber) {
        require(
            studentApprovals[msg.sender][_idNumber],
            "You are not approved to modify this student's data"
        );
        _;
    }

    function enrollStudent(
        string memory _name,
        uint256 _idNumber,
        uint256 _enrollmentYear,
        string memory _department
    ) public onlyOwner {
        require(!students[_idNumber].isEnrolled, "Student already enrolled");

        students[_idNumber] = Student(
            _name,
            _idNumber,
            true,
            _enrollmentYear,
            _department
        );
        studentCount++;

        emit StudentEnrolled(_idNumber, _name, _enrollmentYear, _department);
    }

    function unenrollStudent(uint256 _idNumber) public onlyOwner {
        require(students[_idNumber].isEnrolled, "Student not enrolled");

        string memory name = students[_idNumber].name;
        delete students[_idNumber];
        studentCount--;

        emit StudentUnenrolled(_idNumber, name);
    }

    function updateStudentData(
        uint256 _idNumber,
        string memory _name,
        uint256 _enrollmentYear,
        string memory _department
    ) public onlyApprovedStudent(_idNumber) {
        require(students[_idNumber].isEnrolled, "Student not enrolled");

        students[_idNumber].name = _name;
        students[_idNumber].enrollmentYear = _enrollmentYear;
        students[_idNumber].department = _department;

        emit StudentDataUpdated(_idNumber, _name, _enrollmentYear, _department);
    }

    function getStudentDetails(
        uint256 _idNumber
    )
        public
        view
        returns (string memory, uint256, bool, uint256, string memory)
    {
        require(students[_idNumber].isEnrolled, "Student not enrolled");

        Student memory student = students[_idNumber];
        return (
            student.name,
            student.idNumber,
            student.isEnrolled,
            student.enrollmentYear,
            student.department
        );
    }

    function approveStudentData(
        uint256 _idNumber,
        address _approvedAddress
    ) public onlyOwner {
        studentApprovals[_approvedAddress][_idNumber] = true;
    }

    function revokeStudentDataApproval(
        uint256 _idNumber,
        address _approvedAddress
    ) public onlyOwner {
        studentApprovals[_approvedAddress][_idNumber] = false;
    }
}
