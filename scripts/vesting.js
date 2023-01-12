async function main() {
    const Vesting = await ethers.getContractFactory("Vesting");
  
    // Start deployment, returning a promise that resolves to a contract object
    const VestingContract = await Vesting.deploy("0x673E41d4545CC82df37C48D1Ab6b024470acB3B1");
    console.log("Contract deployed to address:", VestingContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });