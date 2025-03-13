// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title VesselRegistration
 * @dev This contract maintains an authoritative registry of vessels, keyed by IMO number.
 *      Each vessel entry includes an owner address and a flag state. Only the contract
 *      administrator (set upon deployment) can add or modify vessel records.
 */
contract VesselRegistration {
    /**
     * @dev Stores core vessel information:
     *      - imoNumber: The unique IMO identifier.
     *      - owner: The Ethereum address of the vessel's owner or operator.
     *      - flagState: A string representing the vessel's flag state (e.g., "Panama").
     */
    struct Vessel {
        string imoNumber;
        address owner;
        string flagState;
    }

    /// @notice Mapping of IMO numbers to their vessel records.
    mapping(string => Vessel) private vessels;

    /// @notice Address of the contract administrator (the entity with permission to register or update vessels).
    address public immutable admin;

    /**
     * @dev Restricts function calls to only the admin address.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    /**
     * @dev Initializes the contract by designating the deployer as `admin`.
     */
    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Registers or updates a vessel record, including its owner address and flag state.
     * @dev Only callable by the contract administrator.
     * @param imoNumber The unique IMO identifier for the vessel.
     * @param ownerAddr The owner or operator's Ethereum address.
     * @param flagState The vessel's flag state (e.g., a country code).
     */
    function registerVessel(
        string memory imoNumber,
        address ownerAddr,
        string memory flagState
    ) public onlyAdmin {
        vessels[imoNumber] = Vessel({
            imoNumber: imoNumber,
            owner: ownerAddr,
            flagState: flagState
        });
    }

    /**
     * @notice Checks whether a vessel is registered under a given IMO number.
     * @param imoNumber The IMO number to look up.
     * @return True if the vessel exists in the registry, false otherwise.
     */
    function isVesselRegistered(string calldata imoNumber)
        external
        view
        returns (bool)
    {
        return bytes(vessels[imoNumber].imoNumber).length > 0;
    }

    /**
     * @notice Retrieves the recorded flag state for a specified vessel.
     * @param imoNumber The IMO number of the vessel.
     * @return A string representing the vessel's flag state.
     */
    function getFlagState(string calldata imoNumber)
        external
        view
        returns (string memory)
    {
        return vessels[imoNumber].flagState;
    }

    /**
     * @notice Retrieves the owner address for a specified vessel.
     * @param imoNumber The IMO number of the vessel.
     * @return The Ethereum address stored as the owner of this vessel.
     */
    function getVesselOwner(string calldata imoNumber)
        external
        view
        returns (address)
    {
        return vessels[imoNumber].owner;
    }
}


