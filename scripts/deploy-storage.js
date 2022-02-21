const { a, deploy } = require("../lib/utils")

const main = async () => {
  const storage = await deploy("Storage")
  console.log(`Storage: ${a(storage)}`)
}

main()
