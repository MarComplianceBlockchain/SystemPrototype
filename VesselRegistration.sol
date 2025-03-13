const VesselRegistration = artifacts.require("VesselRegistration");

contract("VesselRegistration", (accounts) => {
  let vesselRegInstance;
  const admin = accounts[0];
  const nonAdmin = accounts[1];
  const someVesselOwner = accounts[2];

  before(async () => {
    vesselRegInstance = await VesselRegistration.deployed();
  });

  it("should set deployer as admin", async () => {
    const actualAdmin = await vesselRegInstance.admin();
    assert.equal(actualAdmin, admin, "Deployer is the admin");
  });

  it("should allow only admin to register a vessel", async () => {
    try {
      await vesselRegInstance.registerVessel(
        "IMO_BAD",
        nonAdmin,   // new contract expects an address for the owner
        "Bahamas",
        { from: nonAdmin }
      );
      assert.fail("Expected revert not received");
    } catch (error) {
      assert(
        error.message.includes("Not authorized"),
        "Should revert with 'Not authorized'"
      );
    }
  });

  it("should register a vessel from admin with an owner address", async () => {
    await vesselRegInstance.registerVessel("IMO_12345", someVesselOwner, "Panama", { from: admin });
    // Check if stored
    const isRegistered = await vesselRegInstance.isVesselRegistered("IMO_12345");
    assert.equal(isRegistered, true, "Should be registered");
  });

  it("should retrieve the correct flagState", async () => {
    const flag = await vesselRegInstance.getFlagState("IMO_12345");
    assert.equal(flag, "Panama", "Flag state should match what was set");
  });

  it("should retrieve the correct vessel owner address", async () => {
    const actualOwner = await vesselRegInstance.getVesselOwner("IMO_12345");
    assert.equal(actualOwner, someVesselOwner, "Should store the correct address as owner");
  });

  it("should return false for unregistered vessel", async () => {
    const isRegistered = await vesselRegInstance.isVesselRegistered("IMO_NOTHING");
    assert.equal(isRegistered, false, "Should return false for a vessel not in the mapping");
  });
});


