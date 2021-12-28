require("dotenv").config();

const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const secretFile = process.env.SECRET_FILE || ".secret.local";
const mnemonic = fs.readFileSync(secretFile).toString().trim();
const infura_key = process.env.INFURA_KEY;

module.exports = {
  networks: {
    ganache: {
      host: "127.0.0.1",
      port: 7545,
      network_id: 5777,
    },
    develop: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "10",
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider(
          mnemonic,
          "https://rinkeby.infura.io/v3/" + infura_key
        );
      },
      network_id: 4,
      gas: 4500000,
      gasPrice: 10000000000,
    },
    bsc_testnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          `https://data-seed-prebsc-1-s1.binance.org:8545`
        ),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    bsc: {
      provider: () =>
        new HDWalletProvider(mnemonic, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "^0.8.11",
    },
  },
};
