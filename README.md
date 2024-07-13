Maritime Compliance Blockchain
This repository contains the smart contracts for the sulfur emissions monitoring system, which is part of the Maritime Compliance project. These contracts enable the registration of vessels, recording of sulfur emissions data, and reporting of non-compliance with maritime emission regulations.

Smart Contracts
VesselRegistration.sol
Purpose: Handles the registration of vessels.
Functions:
registerVessel: Allows the admin to register a new vessel by providing its IMO number, owner, and flag state.
isVesselRegistered: Checks if a vessel is registered based on its IMO number.
getFlagState: Retrieves the flag state of a registered vessel using its IMO number.
EmissionData.sol
Purpose: Records sulfur emissions data and checks for compliance.
Functions:
recordEmission: Records emission data for a vessel, including sulfur content, position, and whether it is within an Emissions Control Area (ECA). If a non-compliance event is detected, it automatically triggers the reportNonCompliance function in the Notification contract.
getEmissionData: Retrieves the emission data for a specified vessel.
Notification.sol
Purpose: Records non-compliance notifications.
Functions:
setPortState: Allows the admin to set the port state for a given location.
getPortState: Retrieves the port state for a specified location.
reportNonCompliance: Records a non-compliance notification with details such as vessel ID, message, flag state, and port state.
getNotifications: Returns an array of all recorded non-compliance notifications.
Deployment
To deploy the smart contracts, follow these steps:

Clone the repository:

git clone https://github.com/wquigley1/MarComplianceBlockchain.git
cd MarComplianceBlockchain
Compile and deploy the contracts:

Use Remix IDE to compile and deploy VesselRegistration.sol, Notification.sol, and EmissionData.sol in that order.
Ensure you record the contract addresses after each deployment.
Interact with the contracts:

Register a vessel using the registerVessel function in VesselRegistration.sol.
Set the port state using the setPortState function in Notification.sol.
Record emission data using the recordEmission function in EmissionData.sol.
Usage
Register a Vessel:

Call the registerVessel function with the vessel's IMO number, owner, and flag state.
Example:
registerVessel("IMO1234567", "MSC", "Malta")
Set Port State:

Call the setPortState function with the location and port state.
Example:
setPortState("37.7749N, 122.4194W", "USA")
Record Emission Data:

Call the recordEmission function with the vessel's IMO number, sulfur content, position, and ECA status.
Example:
recordEmission("IMO1234567", 151, "37.7749N, 122.4194W", true)
