const { JsonRpcProvider, Provider } = require("@ethersproject/providers")
const { a, deploy } = require("../lib/utils")
const { utils, Wallet, ContractFactory, Contract } = require("ethers")
const Events = require("../artifacts/contracts/events/EventsPayment.sol/EventsPayment.json")
const Storage = require("../artifacts/contracts/storage/Storage.sol/Storage.json")
const JPYD = require("../lib/JPYD.json")

const { contracts, url, key } = require("../secrets")[
  process.env.HARDHAT_NETWORK
]
const main = async () => {
  const provider = new JsonRpcProvider(url)
  const wallet = new Wallet(key, provider)
  const events = new Contract(contracts.EventsPayment, Events.abi, wallet)
  const storage = new Contract(contracts.Storage, Storage.abi, wallet)
  const jpyd = new Contract(contracts.JPYD, JPYD.abi, wallet)
  const pay = await deploy(
    "Pay",
    50,
    contracts.JPYD,
    contracts.treasury,
    contracts.Storage,
    contracts.EventsPayment
  )
  console.log(`Pay: ${a(pay)}`)
  await events.grantRole(await events.EMITTER_ROLE(), a(pay))
  console.log("emitter role added")
  await storage.grantRole(await storage.EDITOR_ROLE(), a(pay))
  console.log("editor role added")
  await jpyd.grantRole(await jpyd.MINTER_ROLE(), a(pay))
  console.log("minter role added")
}

main()
