const { ethers, deployments, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { assert } = require("chai")

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", function () {
          this.timeout(60000)
          let fundMe, deployer
          const sendValue = ethers.parseEther("0.016")

          beforeEach(async function () {
              const signers = await ethers.getSigners()
              deployer = signers[0]
              const { address: fundMeAddr, abi: fundMeAbi } =
                  await deployments.get("FundMe")
              fundMe = new ethers.Contract(fundMeAddr, fundMeAbi, deployer)
          })

          it("allows people to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              const txResponse = await fundMe.withdraw()
              await txResponse.wait(1)

              const provider = deployer.provider

              const endingBalance = await provider.getBalance(fundMe.target)

              assert.equal(endingBalance, "0")
          })

          xit("allows owner to withdraw", async function () {
              const txResponse = await fundMe.withdraw()
              await txResponse.wait(1)

              const provider = deployer.provider

              const endingBalance = await provider.getBalance(fundMe.target)
              assert.equal(endingBalance.toString(), "0")
          })
      })

// // Error handling at the global level
// process.on("unhandledRejection", (reason, promise) => {
//     console.error(
//         "Unhandled Rejection at: Promise ",
//         promise,
//         " reason: ",
//         reason
//     )
//     // Application specific logging, throwing an error, or other logic here
// })
// process.on("uncaughtException", (error) => {
//     console.error("Uncaught Exception thrown: ", error)
//     // Application specific logging, throwing an error, or other logic here
// })
