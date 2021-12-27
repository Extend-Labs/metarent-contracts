const Metarent = artifacts.require("Metarent");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(Metarent, accounts[0]);

  const metarent = await Metarent.deployed();
};
