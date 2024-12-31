const { assert } = require("chai")
const { deployments, ethers, getNamedAccounts, network } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("FunWithStorage", function () {
          let funWithStorage

          beforeEach(async function () {
              const { deployer } = await getNamedAccounts()
              const signer = await ethers.getSigner(deployer)

              await deployments.fixture(["storage"])

              const { address: funWithStorageAddress, abi: funWithStorageAbi } =
                  await deployments.get("FunWithStorage")
              funWithStorage = new ethers.Contract(
                  funWithStorageAddress,
                  funWithStorageAbi,
                  signer
              )
          })

          describe("constructor", function () {
              it("sets favorite number to 25", async function () {
                  // Arrange
                  const expectedValue = 25
                  // Act
                  const response = await funWithStorage.favoriteNumber()
                  // Assert
                  assert.equal(response, expectedValue)
              })

              it("sets someBool value to true", async function () {
                  const expectedValue = true
                  const response = await funWithStorage.someBool()
                  assert.equal(response, expectedValue)
              })

              it("updates myArray elements correctly", async function () {
                  const expectedValue = 222
                  const response = await funWithStorage.myArray(0)
                  assert.equal(response, expectedValue)
              })

              it("updates myMap data structure correctly", async function () {
                  const expectedValue = true
                  const response = await funWithStorage.myMap(0)
                  assert.equal(response, expectedValue)
              })

              it("updates immutable variable correctly", async function () {
                  const expectedValue = 123
                  const response = await funWithStorage.i_not_in_storage()
                  assert.equal(response, expectedValue)
              })
          })

          describe("doStuff", function () {
              it("does extra random stuff", async function () {
                  const favNum = await funWithStorage.favoriteNumber()
                  const someBool = await funWithStorage.someBool()
                  const expectedNewVar = parseInt(favNum) + 1
                  const expectedSomeBool = !someBool

                  const response = await funWithStorage.doStuff()
                  assert.equal(response[0], expectedNewVar)
                  assert.equal(response[1], expectedSomeBool)
              })
          })
      })
