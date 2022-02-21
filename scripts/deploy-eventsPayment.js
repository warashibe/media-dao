const { a, deploy } = require("../lib/utils")
const main = async () => {
  const events = await deploy("EventsPayment")
  console.log(`EventsPayment: ${a(events)}`)
}

main()
