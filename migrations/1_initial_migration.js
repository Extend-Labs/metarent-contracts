// const Migrations = artifacts.require("Migrations");
const Metarent = artifacts.require("Metarent");

module.exports = function (deployer) {
  // deployer.deploy(Migrations);
  deployer.deploy(Metarent);
};
