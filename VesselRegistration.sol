// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VesselRegistration {
    struct Vessel {
        string imoNumber;
        string owner;
        string flagState;
    }

    mapping(string => Vessel) private vessels; // Use private visibility to restrict direct access
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerVessel(string memory imoNumber, string memory owner, string memory flagState) public onlyAdmin {
        vessels[imoNumber] = Vessel(imoNumber, owner, flagState);
    }

    function isVesselRegistered(string calldata imoNumber) public view returns (bool) {
        return bytes(vessels[imoNumber].imoNumber).length > 0;
    }

    function getFlagState(string calldata imoNumber) public view returns (string memory) {
        return vessels[imoNumber].flagState;
    }
}
