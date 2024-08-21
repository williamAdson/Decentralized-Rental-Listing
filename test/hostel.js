const Hostel = artifacts.require("Hostel");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Hostel", function (/* accounts */) {
  it("should assert true", async function () {
    await Hostel.deployed();
    return assert.isTrue(true);
  });
});
