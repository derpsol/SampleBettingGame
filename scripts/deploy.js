async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("Meow");
  const token = await Token.deploy('0xA3D40B9be89e1074309Ed8EFf9F3215F323C8b19', '0x7dDb046ab13D024e68714cA771d2b69D250E9638');

  console.log("Token address:", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });