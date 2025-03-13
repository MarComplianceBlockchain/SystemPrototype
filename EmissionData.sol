// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./VesselRegistration.sol";
import "./Notification.sol";

/**
 * @title EmissionData
 * @dev This contract records sulfur emission data for each vessel, verifies compliance
 *      against ECA and non-ECA thresholds, and triggers non-compliance alerts. Vessel data
 *      (ownership and registration) is referenced from VesselRegistration, and any alerts
 *      are logged via Notification.
 */
contract EmissionData {
    /**
     * @dev Represents a single emission record, including:
     *      - timestamp: The block time when this emission was recorded.
     *      - vesselId: The vessel's unique identifier (e.g., IMO number).
     *      - sulfurContent: The measured sulfur level (scaled as needed).
     *      - position: Geographic identifier (lat/long or region).
     *      - isECA: Indicates whether the position is inside an Emission Control Area.
     *      - isCompliant: True if below the applicable sulfur limit.
     *      - portState: A user-provided descriptor of the local port/region (e.g., "USA").
     */
    struct Emission {
        uint256 timestamp;
        string vesselId;
        uint256 sulfurContent;
        string position;
        bool isECA;
        bool isCompliant;
        string portState;
    }

    /// @dev Mapping each vessel ID to an array of all recorded emissions (historical auditing).
    mapping(string => Emission[]) private vesselEmissions;

    /// @notice Constants defining the sulfur limits for ECA vs. non-ECA areas.
    uint256 private constant ECA_SULFUR_LIMIT = 100;     // e.g., 0.10%
    uint256 private constant NON_ECA_SULFUR_LIMIT = 500; // e.g., 0.50%

    /// @notice References to external contracts:
    ///         - VesselRegistration: verifies registration and retrieves owners.
    ///         - Notification: logs non-compliance events.
    VesselRegistration public immutable vesselRegistration;
    Notification public notification;

    /// @notice The contract admin, set at deployment (optional extra privilege).
    address public immutable admin;

    /// @dev Restricts certain functions to only the admin address.
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    /**
     * @dev Checks if the provided vessel ID is registered in VesselRegistration.
     */
    modifier onlyRegisteredVessel(string memory vesselId) {
        require(
            vesselRegistration.isVesselRegistered(vesselId),
            "Vessel not registered"
        );
        _;
    }

    /**
     * @dev Ensures that the caller is the registered owner of the specified vessel.
     */
    modifier onlyVesselOwner(string memory vesselId) {
        address vesselOwner = vesselRegistration.getVesselOwner(vesselId);
        require(msg.sender == vesselOwner, "Not the vessel owner");
        _;
    }

    /**
     * @param vesselRegistrationAddress The deployed VesselRegistration contract address.
     * @param notificationAddress The deployed Notification contract address.
     */
    constructor(address vesselRegistrationAddress, address notificationAddress) {
        vesselRegistration = VesselRegistration(vesselRegistrationAddress);
        notification = Notification(notificationAddress);
        admin = msg.sender;
    }

    /**
     * @dev Emitted whenever a new emission record is created.
     * @param vesselId The vessel's unique identifier (e.g., IMO number).
     * @param sulfurContent The measured sulfur content (scaled).
     * @param position The position or region where measurement occurred.
     * @param isECA True if the location is within an Emission Control Area.
     * @param isCompliant True if the sulfur level does not exceed the relevant threshold.
     * @param portState User-supplied text describing the port or local region (e.g., "Canada").
     */
    event EmissionRecorded(
        string vesselId,
        uint256 sulfurContent,
        string position,
        bool isECA,
        bool isCompliant,
        string portState
    );

    /**
     * @notice Records a new sulfur emission entry for the specified vessel, verifying
     *         whether it remains below the permissible limit (0.10% in an ECA, 0.50% otherwise).
     * @param vesselId The vessel identifier (must already be registered).
     * @param sulfurContent The measured sulfur content (scaled), e.g., 100 => 0.10%.
     * @param position A location descriptor (lat/long or city name).
     * @param isECA Whether the position is within an Emission Control Area.
     * @param portState An additional string (e.g., "USA") labeling the port or region.
     */
    function recordEmission(
        string memory vesselId,
        uint256 sulfurContent,
        string memory position,
        bool isECA,
        string memory portState
    )
        public
        onlyRegisteredVessel(vesselId)
        onlyVesselOwner(vesselId)
    {
        // Determine compliance by comparing sulfurContent to the appropriate limit
        bool isCompliant = isECA
            ? (sulfurContent <= ECA_SULFUR_LIMIT)
            : (sulfurContent <= NON_ECA_SULFUR_LIMIT);

        // Create and store a new Emission record
        Emission memory newEmission = Emission({
            timestamp: block.timestamp,
            vesselId: vesselId,
            sulfurContent: sulfurContent,
            position: position,
            isECA: isECA,
            isCompliant: isCompliant,
            portState: portState
        });
        vesselEmissions[vesselId].push(newEmission);

        // Emit an event for the recorded emission
        emit EmissionRecorded(
            vesselId,
            sulfurContent,
            position,
            isECA,
            isCompliant,
            portState
        );

        // If not compliant, build and log a non-compliance report via Notification
        if (!isCompliant) {
            string memory flagState = vesselRegistration.getFlagState(vesselId);
            // Construct a domain-specific message
            string memory message = isECA
                ? "Non-compliance: Exceeds 0.10% sulfur limit in ECA."
                : "Non-compliance: Exceeds 0.50% sulfur limit outside ECA.";

            notification.reportNonCompliance(
                vesselId,
                message,
                flagState,
                portState
            );
        }
    }

    /**
     * @notice Allows the admin to update the Notification contract reference if needed
     *         (for instance, if deploying a new Notification contract).
     * @param newNotification The address of the new Notification contract.
     */
    function setNotificationContract(address newNotification) external onlyAdmin {
        notification = Notification(newNotification);
    }

    /**
     * @notice Retrieves the entire emission history for a given vessel ID.
     * @param vesselId The vessel's identifier (e.g., IMO number).
     * @return An array of Emission records, in chronological order of insertion.
     */
    function getEmissionHistory(string calldata vesselId)
        external
        view
        returns (Emission[] memory)
    {
        return vesselEmissions[vesselId];
    }
}

