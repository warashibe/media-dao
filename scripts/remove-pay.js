const { JsonRpcProvider, Provider } = require("@ethersproject/providers")
const { a, deploy } = require("../lib/utils")
const { utils, Wallet, ContractFactory, Contract } = require("ethers")
const Events = require("../artifacts/contracts/events/EventsPayment.sol/EventsPayment.json")
const Storage = require("../artifacts/contracts/storage/Storage.sol/Storage.json")
const JPYD = require("../lib/JPYD.json")

const { contracts, url, key, jpyd_owner_key } = require("../secrets")[
  process.env.HARDHAT_NETWORK
]
const main = async () => {
  const provider = new JsonRpcProvider(url)
  const wallet = new Wallet(key, provider)
  const wallet_jpyd_owner = new Wallet(jpyd_owner_key, provider)

  const events = new Contract(contracts.EventsPayment, Events.abi, wallet)
  const storage = new Contract(contracts.Storage, Storage.abi, wallet)
  const jpyd = new Contract(contracts.JPYD, JPYD.abi, wallet_jpyd_owner)

  const tx1 = await events.revokeRole(
    await events.EMITTER_ROLE(),
    contracts.previous_Pay
  )
  await tx1.wait()
  console.log("emitter role removed")
  const tx2 = await storage.revokeRole(
    await storage.EDITOR_ROLE(),
    contracts.previous_Pay
  )
  await tx2.wait()
  console.log("editor role removed")
  const tx3 = await jpyd.revokeRole(
    await jpyd.MINTER_ROLE(),
    contracts.previous_Pay
  )
  await tx3.wait()
  console.log("minter role removed")
}

main()
