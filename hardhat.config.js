require("@nomicfoundation/hardhat-toolbox");
/** @type import('hardhat/config').HardhatUserConfig */

const ALCHEMY_API_KEY = "QARk6wvaaHlcADJr55SrUhFmACjgP0lZ";

const GOERLI_PRIVATE_KEY = "737632c72dca33c3b11f2db3003229b1c311429f42380fa6dcff83cbf083a74d";

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
      goerli: 'DEHCB9QGHRA42MIX935Z9SQI9DRD3FYYDG'
    }
  }
};
