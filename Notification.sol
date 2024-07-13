// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Notification {
    struct ComplianceNotification {
        uint256 timestamp;
        string vesselId;
        string message;
        string flagState;
        string portState;
    }

    ComplianceNotification[] public notifications;
    address public admin;

    mapping(string => string) public portStates;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setPortState(string memory location, string memory portState) public onlyAdmin {
        portStates[location] = portState;
    }

    function getPortState(string memory location) public view returns (string memory) {
        return portStates[location];
    }

    function reportNonCompliance(
        string memory vesselId,
        string memory message,
        string memory flagState,
        string memory portState
    ) public {
        notifications.push(ComplianceNotification(block.timestamp, vesselId, message, flagState, portState));
        emit NonComplianceReported(vesselId, message, flagState, portState);
    }

    function getNotifications() public view returns (ComplianceNotification[] memory) {
        return notifications;
    }

    event NonComplianceReported(
        string vesselId,
        string message,
        string flagState,
        string portState
    );
}
