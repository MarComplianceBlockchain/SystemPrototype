// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title Notification
 * @dev This contract stores and logs non-compliance alerts for vessels, including
 *      relevant details such as flag state and a user-defined port or region label.
 *      Only an authorized EmissionData contract may file new alerts.
 */
contract Notification {
    /**
     * @dev Represents a single non-compliance event, capturing essential data
     *      about the vessel, the violation, and the location or port details.
     */
    struct ComplianceNotification {
        uint256 timestamp;
        string vesselId;
        string message;
        string flagState;
        string portState;
    }

    /// @notice A dynamic array holding all non-compliance notifications ever recorded.
    ComplianceNotification[] public notifications;

    /// @notice The admin address (the contract deployer).
    address public immutable admin;

    /// @notice The EmissionData contract authorized to call reportNonCompliance.
    address public emissionDataContract;

    /// @dev Restricts certain functions to only the admin account.
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    /// @dev Restricts certain functions to only the EmissionData contract.
    modifier onlyEmissionData() {
        require(msg.sender == emissionDataContract, "Not EmissionData contract");
        _;
    }

    /**
     * @dev Triggered whenever a new non-compliance event is reported to the contract.
     * @param vesselId The unique ID or IMO number of the vessel.
     * @param message A brief description of the non-compliance issue.
     * @param flagState The vessel's flag state (e.g., "Panama", "Liberia").
     * @param portState A string indicating port or region details (e.g., "USA").
     */
    event NonComplianceReported(
        string vesselId,
        string message,
        string flagState,
        string portState
    );

    /**
     * @dev Assigns the deploying address as admin and optionally sets an initial
     *      EmissionData contract address. The EmissionData address can be zero if
     *      not yet known (Approach A).
     * @param _emissionDataContract The address of the EmissionData contract with
     *                              permission to call reportNonCompliance.
     */
    constructor(address _emissionDataContract) {
        admin = msg.sender;
        emissionDataContract = _emissionDataContract;
    }

    /**
     * @notice Allows the admin to modify the EmissionData contract address if it
     *         changes or was initially set to zero.
     * @dev Only callable by the admin.
     * @param _emissionData The new address of the authorized EmissionData contract.
     */
    function setEmissionDataContract(address _emissionData) external onlyAdmin {
        emissionDataContract = _emissionData;
    }

    /**
     * @notice Creates a new non-compliance record with the specified details.
     * @dev Restricted to calls from the EmissionData contract only.
     * @param vesselId The vessel's unique identifier or IMO number.
     * @param message A concise description of the violation (e.g., "Exceeds 0.10%").
     * @param flagState The vessel's flag state, as recorded in VesselRegistration.
     * @param portState The relevant port or regional label (e.g., "USA").
     */
    function reportNonCompliance(
        string memory vesselId,
        string memory message,
        string memory flagState,
        string memory portState
    ) external onlyEmissionData {
        notifications.push(
            ComplianceNotification({
                timestamp: block.timestamp,
                vesselId: vesselId,
                message: message,
                flagState: flagState,
                portState: portState
            })
        );
        emit NonComplianceReported(vesselId, message, flagState, portState);
    }

    /**
     * @notice Retrieves the full array of non-compliance notifications logged to date.
     * @return An array of ComplianceNotification structs containing all recorded alerts.
     */
    function getNotifications()
        external
        view
        returns (ComplianceNotification[] memory)
    {
        return notifications;
    }
}
