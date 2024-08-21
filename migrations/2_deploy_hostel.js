const Hostel = artifacts.require("Hostel");

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Hostel, "HOSTEL DEPLOYED");
};