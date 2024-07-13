// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VesselRegistration.sol";
import "./Notification.sol";

contract EmissionData {
    struct Emission {
        uint256 timestamp;
        string vesselId;
        uint256 sulfurContent;
        string position;
        bool isECA;
        bool isCompliant;
    }

    mapping(string => Emission) public emissions;
    VesselRegistration public vesselRegistration;
    Notification public notification;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    modifier onlyRegisteredVessel(string memory vesselId) {
        require(vesselRegistration.isVesselRegistered(vesselId), "Vessel not registered");
        _;
    }

    constructor(address vesselRegistrationAddress, address notificationAddress) {
        vesselRegistration = VesselRegistration(vesselRegistrationAddress);
        notification = Notification(notificationAddress);
        admin = msg.sender;
    }

    function recordEmission(
        string memory vesselId,
        uint256 sulfurContent,
        string memory position,
        bool isECA
    ) public onlyRegisteredVessel(vesselId) {
        bool isCompliant = (isECA && sulfurContent <= 100) || (!isECA && sulfurContent <= 500);
        emissions[vesselId] = Emission(block.timestamp, vesselId, sulfurContent, position, isECA, isCompliant);
        emit EmissionRecorded(vesselId, sulfurContent, position, isECA, isCompliant);

        if (!isCompliant) {
            string memory flagState = vesselRegistration.getFlagState(vesselId);
            string memory portState = notification.getPortState(position);
            string memory message = isECA
                ? "Non-compliance detected: Sulfur content exceeds 0.10% in ECA."
                : "Non-compliance detected: Sulfur content exceeds 0.50% outside ECA.";
            notification.reportNonCompliance(vesselId, message, flagState, portState);
        }
    }

    function getEmissionData(string memory vesselId) public view returns (Emission memory) {
        return emissions[vesselId];
    }

    event EmissionRecorded(
        string vesselId,
        uint256 sulfurContent,
        string position,
        bool isECA,
        bool isCompliant
    );
}
