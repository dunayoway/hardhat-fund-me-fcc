const { ethers, deployments } = require("hardhat")

async function main() {
    const signers = await ethers.getSigners()
    const deployer = signers[0]
    const { address: fundMeAddr, abi: fundMeAbi } = await deployments.get(
        "FundMe"
    )
    const fundMe = new ethers.Contract(fundMeAddr, fundMeAbi, deployer)
    console.log("Funding Contract...")
    const txResponse = await fundMe.fund({ value: ethers.parseEther("0.017") })
    await txResponse.wait(1)
    console.log("Funded")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
