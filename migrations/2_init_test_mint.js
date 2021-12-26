const MetarentNFT = artifacts.require("MetarentNFT");

module.exports = async (deployer) => {
  await deployer.deploy(MetarentNFT);

  const nft = await MetarentNFT.deployed();
  let tokenId = await nft.mintNFT(
    "0xA7fDAc5d15b15042963b17e26B7e49eD69C06aEa",
    "http://metarent.me"
  );
  console.log("tokenId", tokenId);
};
