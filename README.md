# Maritime Compliance Blockchain

This repository provides the updated smart contracts for a sulfur emissions monitoring system in the maritime domain. These contracts support vessel registration, real-time recording of emissions data, and on-chain reporting of any non-compliance with emission thresholds.

## Smart Contracts

### `VesselRegistration.sol`
- **Purpose**: Maintains a registry of vessels, indexed by IMO number.  
- **Key Functions**:  
  - `registerVessel(string imoNumber, address ownerAddr, string flagState)`:  
    Allows the admin to register a new vessel by specifying its IMO number, owner’s Ethereum address, and a flag state.  
  - `isVesselRegistered(string imoNumber) -> bool`:  
    Checks whether a vessel is registered under a specific IMO number.  
  - `getFlagState(string imoNumber) -> string`:  
    Retrieves the recorded flag state for the given vessel.  
  - `getVesselOwner(string imoNumber) -> address`:  
    Retrieves the stored owner address for the specified vessel.

### `EmissionData.sol`
- **Purpose**: Records sulfur emission readings for vessels, verifies whether those readings exceed the allowed threshold (0.10% in an Emission Control Area (ECA), 0.50% otherwise), and triggers non-compliance alerts if necessary.  
- **Key Functions**:  
  - `recordEmission(string vesselId, uint256 sulfurContent, string position, bool isECA, string portState)`:  
    Logs a new emission event for the vessel, including sulfur level, position, whether it is in an ECA, and a user-supplied `portState`. If the reading is non-compliant, it automatically calls `reportNonCompliance` in the `Notification` contract.  
  - `getEmissionHistory(string vesselId) -> Emission[]`:  
    Returns the complete emission record history for a given vessel, providing insights into all past emission entries.

### `Notification.sol`
- **Purpose**: Stores non-compliance notifications reported by the `EmissionData` contract.  
- **Key Functions**:  
  - `setEmissionDataContract(address _emissionData)`:  
    Allows the admin to assign or change which `EmissionData` contract is authorized to invoke `reportNonCompliance`.  
  - `reportNonCompliance(string vesselId, string message, string flagState, string portState)`:  
    Records a non-compliance alert containing the vessel ID, a short explanatory message, the vessel’s flag state, and a user-supplied port region. Only calls from the authorized `EmissionData` contract succeed.  
  - `getNotifications() -> ComplianceNotification[]`:  
    Retrieves an array of all non-compliance alerts previously recorded on-chain.

## Deployment

To deploy the smart contracts, follow these steps:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/wquigley1/MarComplianceBlockchain.git
    cd MarComplianceBlockchain
    ```

2. **Compile and Deploy the Contracts**:
    - Use your preferred environment (e.g., Remix IDE or Truffle) to compile the contracts in the following order:
      1. `VesselRegistration.sol`
      2. `Notification.sol`
      3. `EmissionData.sol`
    - Record the deployed contract addresses for future interactions.
    - If you deploy `Notification` with a placeholder (dummy) address for the authorized EmissionData contract, update it by calling the `setEmissionDataContract(...)` function from the admin account.

3. **Interact with the Contracts**:
    - Register vessels via the `registerVessel` function in `VesselRegistration.sol`.
    - Record emission data using the `recordEmission` function in `EmissionData.sol`.
    - Non-compliant emission readings automatically trigger the `reportNonCompliance` function in `Notification.sol`.

## Usage

1. **Register a Vessel**:
    - Call the `registerVessel(string imoNumber, address ownerAddr, string flagState)` function with the vessel’s details.
    - Example:
      ```solidity
      registerVessel("IMO1234567", 0xABCD..., "Panama");
      ```
      This registers the vessel with the given IMO number, assigns the specified owner address, and sets its flag state.

2. **Record Emission Data**:
    - The vessel’s owner must call the `recordEmission(string vesselId, uint256 sulfurContent, string position, bool isECA, string portState)` function.
    - Example:
      ```solidity
      recordEmission("IMO1234567", 170, "32.7157N,117.1611W", true, "USA");
      ```
      This records a sulfur emission reading. If the measured sulfur content exceeds the threshold (0.10% in an ECA or 0.50% otherwise), the contract automatically invokes `reportNonCompliance` in the `Notification` contract.

3. **Retrieve Emission History**:
    - Call `getEmissionHistory(string vesselId)` in `EmissionData.sol` to obtain all recorded emissions for the vessel.
    - Example:
      ```solidity
      Emission[] memory history = getEmissionHistory("IMO1234567");
      ```

4. **View Non-Compliance Notifications**:
    - Call `getNotifications()` in `Notification.sol` to view the complete log of non-compliance events.



