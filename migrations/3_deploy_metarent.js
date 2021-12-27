const Metarent = artifacts.require("Metarent");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(Metarent);

  const metarent = await Metarent.deployed();
};
