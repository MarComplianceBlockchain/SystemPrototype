// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 * @title VesselRegistration
 * @dev Stores and verifies the registration details of vessels (by IMO number).
 *      Only an admin can add or modify vessel records.
 */
contract VesselRegistration {
    /// @dev Holds basic vessel data: IMO number, owner (as an address), and flag state.
    struct Vessel {
        string imoNumber;
        address owner;
        string flagState;
    }

    /// @notice Mapping of IMO number -> Vessel details.
    mapping(string => Vessel) private vessels;

    /// @notice Address of the contract administrator (e.g., maritime authority).
    address public immutable admin;

    /// @dev Restricts access to admin-only functions.
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    /**
     * @dev Initializes the contract, setting the deployer as `admin`.
     */
    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Registers a new vessel.
     * @param imoNumber The unique IMO number for the vessel.
     * @param ownerAddr The Ethereum address of the vessel owner or operator.
     * @param flagState The vessel's flag state (e.g., country code).
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
     * @notice Checks if a vessel is registered by IMO number.
     * @param imoNumber The IMO number to query.
     * @return True if the vessel is registered, false otherwise.
     */
    function isVesselRegistered(string calldata imoNumber)
        external
        view
        returns (bool)
    {
        return bytes(vessels[imoNumber].imoNumber).length > 0;
    }

    /**
     * @notice Retrieves the flag state of a given vessel.
     * @param imoNumber The IMO number of the vessel.
     * @return The flag state as a string.
     */
    function getFlagState(string calldata imoNumber)
        external
        view
        returns (string memory)
    {
        return vessels[imoNumber].flagState;
    }

    /**
     * @notice Retrieves the owner address of a given vessel.
     * @param imoNumber The IMO number of the vessel.
     * @return The owner (Ethereum address) stored for this vessel.
     */
    function getVesselOwner(string calldata imoNumber)
        external
        view
        returns (address)
    {
        return vessels[imoNumber].owner;
    }
}



