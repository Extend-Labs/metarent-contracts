const Metarent = artifacts.require("Metarent");
const MetarentNFT = artifacts.require("MetarentNFT");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(Metarent, accounts[0]);

  const nft = await MetarentNFT.deployed();
  const metarent = await Metarent.deployed();

  console.log(">>> nft address:", nft.address);
  console.log(">>> contract address:", metarent.address);

  await metarent.setLending(nft.address, "1", 1, 2, 3);
};
