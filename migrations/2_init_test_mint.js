const MetarentNFT = artifacts.require("MetarentNFT");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(MetarentNFT);

  const nft = await MetarentNFT.deployed();
  let tokenId = await nft.mintNFT(accounts[0], "http://metarent.me");
  console.log(">>>", "account", accounts[0]);
  console.log(">>>", "tokenId", tokenId);
};
