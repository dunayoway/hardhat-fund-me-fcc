const { ethers, deployments } = require("hardhat")

async function main() {
    const signers = await ethers.getSigners()
    const deployer = signers[0]
    const { address: fundMeAddr, abi: fundMeAbi } = await deployments.get(
        "FundMe"
    )
    const fundMe = new ethers.Contract(fundMeAddr, fundMeAbi, deployer)
    console.log("Funding...")
    const txResponse = await fundMe.withdraw()
    await txResponse.wait(1)
    console.log("Got it back!")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
