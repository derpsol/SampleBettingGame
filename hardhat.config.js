require("@nomicfoundation/hardhat-toolbox");
/** @type import('hardhat/config').HardhatUserConfig */

const ALCHEMY_API_KEY = "sdfsdfsfsdfsdf";

const GOERLI_PRIVATE_KEY = "sdfsdfsdfsf";

module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      goerli: 'sdfsdfsdfdf'
    }
  }
};
