const { Contract, ContractFactory, Signer, Wallet, utils } = require("ethers")
const { expect } = require("chai")
const { from18, to18, a, b, deploy, deployJSON } = require("../lib/utils")
const _JPYD = require("../lib/JPYD")

describe("Pay", function () {
  let deployer, treasury, sender, receiver
  let storage, jpyd, pay, events
  beforeEach(async () => {
    ;[deployer, treasury, sender, receiver] = await ethers.getSigners()
    storage = await deploy("Storage")
    jpyd = await deployJSON(_JPYD, deployer)
    events = await deploy("EventsPayment")
    pay = await deploy("Pay", 50, a(jpyd), a(treasury), a(storage), a(events))
    await events.grantRole(await events.EMITTER_ROLE(), a(pay))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(pay))
    await jpyd.grantRole(await jpyd.MINTER_ROLE(), a(pay))
    await pay.setRate(to18("15"))
  })
  it("Should mint JPYD and grant IVP/PVP", async function () {
    const before = from18(await receiver.getBalance()) * 1
    const before_treasury = from18(await treasury.getBalance()) * 1
    await pay
      .connect(sender)
      .pay(a(receiver), "payment", 1000, { value: to18("10") })
    expect((await b(jpyd, sender)) * 1).to.equal(15)
    const after = from18(await receiver.getBalance()) * 1
    const after_treasury = from18(await treasury.getBalance()) * 1
    expect(after - before).to.equal(9)
    expect(after_treasury - before_treasury).to.equal(1)
    expect(from18(await pay.getTotalMined()) * 1).to.equal(15)
    expect(from18(await pay.getIVP(a(sender))) * 1).to.equal(15)
    expect(from18(await pay.getPVP(a(receiver))) * 1).to.equal(15)
  })
})
