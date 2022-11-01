import fs from 'fs'
import { ethers, utils, BigNumber } from 'ethers'
import axios from 'axios'
import baoV1Abi from './abi/baov1.json'
import { Account, SubgraphAccount, SubgraphResult } from './types'
import chalk from 'chalk'

// -------------------------------
// CONSTANTS
// -------------------------------

const SNAPSHOT_FILE = `${__dirname}/../snapshot.json`

// These EOAs are banned from distribution and have their balances subtracted.
const WALLETS = {
  baoDevelopment: "0x8f5d46FCADEcA93356B70F40858219bB1FBf6088",
  baoLiquidity: "0x3f3243E7776122B1b968b5E74B3DdB971FBed9de",
  baoCommunity: "0x609991ca0Ae39BC4EAF2669976237296D40C2F31",
}

// -------------------------------
// SNAPSHOT VERIFICATION
// -------------------------------

const verifySnapshot = async () => {
  console.log('Checking for duplicates and computing totals...')
  const snapshot: Account[] = JSON.parse(fs.readFileSync(SNAPSHOT_FILE).toString())

  const mainnetProvider = new ethers.providers.JsonRpcProvider("https://eth-mainnet.g.alchemy.com/v2/1GSIFV11NKqjpEcKScGIMY5gAXZLvE0S")
  const bao = new ethers.Contract('0x374CB8C27130E2c9E04F44303f3c8351B9De61C1', baoV1Abi, mainnetProvider)
  const xdaiProvider = new ethers.providers.JsonRpcProvider('https://rpc.gnosischain.com/')
  const baoCx = new ethers.Contract('0xe0d0b1DBbCF3dd5CAc67edaf9243863Fd70745DA', baoV1Abi, xdaiProvider)

  const devLockMain = await bao.lockOf(WALLETS.baoDevelopment)
  const liqLockMain = await bao.lockOf(WALLETS.baoLiquidity)
  const comLockMain = await bao.lockOf(WALLETS.baoCommunity)
  const devLockXdai = await baoCx.lockOf(WALLETS.baoDevelopment) 
  const liqLockXdai = await baoCx.lockOf(WALLETS.baoLiquidity)   
  const comLockXdai = await baoCx.lockOf(WALLETS.baoCommunity)   

  const mainnetLocked = (await bao.lockedSupply())
    .sub(devLockMain)
    .sub(liqLockMain)
    .sub(comLockMain)
  const xdaiLocked = (await baoCx.lockedSupply())
    .sub(devLockXdai)
    .sub(liqLockXdai)
    .sub(comLockXdai)
  const realTotal = mainnetLocked.add(xdaiLocked)

  const exists = []
  let total = BigNumber.from(0)
  let newTotal = BigNumber.from(0)
  snapshot.forEach((account: Account) => {
    if (exists.includes(account.address)) console.log('DUPLICATE')
    total = total.add(BigNumber.from(account.amount))
    newTotal = newTotal.add(BigNumber.from(account.amount).div(1e4))
    exists.push(account.address)
  })

  // subtract the balances of Baoman's three EOAs that are banned from distribution.

  console.log(chalk.greenBright('Done!'))
  console.log(`${chalk.cyanBright('Accounts:')} ${exists.length}`)
  console.log(`${chalk.cyanBright('Total locked BAO from snapshot:')} ${total.toString()} or ${utils.formatUnits(total)}`)
  console.log(`${chalk.cyanBright('Total locked BAO from contracts:')} ${realTotal.toString()} or ${utils.formatUnits(realTotal)}`)
  console.log(`${chalk.cyanBright('Equivalent with new cap:')} ${newTotal.toString()}`)
  console.log(
    `${chalk.cyanBright('Actual Locked Supply:')} ${
      mainnetLocked.toString()
    } ${chalk.blueBright('(ETH)')} | ${xdaiLocked.toString()} ${chalk.yellow('(XDAI)')} | ${
      mainnetLocked.add(xdaiLocked).toString()
    } ${chalk.greenBright('(TOTAL)')}`
  )
  console.log(`Snapshot is ${
    mainnetLocked.add(xdaiLocked).eq(total) ? `${chalk.greenBright('VALID')} - ${
      mainnetLocked.add(xdaiLocked).toString()
    } (${chalk.greenBright('Real Total')}) = ${total.toString()} (${
      chalk.greenBright('Snapshot Total')
    })` : chalk.bold(chalk.red('INVALID'))
  }`) // Should always be valid!
}

// -------------------------------
// SNAPSHOT GENERATION
// -------------------------------

const takeSnapshot = async () => {
  let lockedBalances: Account[] = []

  const getQuery = (i: number) =>
    `
      query {
        users(skip:${i}, first:1000) {
          id
          amount
        }
      }
    `

  console.log(`Fetching ${chalk.blueBright('Mainnet')} data from subgraph...`)
  for (let i = 0;;i += 1000) {
    const query = getQuery(i)
    //'https://api.thegraph.com/subgraphs/name/zfogg/bao-master-farmer',
    const { data: mainnet }: SubgraphResult = await axios.post(
      'https://api.thegraph.com/subgraphs/name/zfogg/bao-token-mainnet',
      { query }
    )
    if (mainnet.errors) break

    lockedBalances = lockedBalances.concat(
      mainnet.data.users.map((account: SubgraphAccount) => ({
        address: account.id,
        amount: account.amount
      }))
    )
  }

  const mainnetAddresses: string[] = lockedBalances.map((account: Account) => account.address)
  console.log(`${chalk.greenBright('Done!')} Found ${chalk.yellowBright(mainnetAddresses.length)} addresses.`)

  console.log(`Fetching ${chalk.yellow('XDAI')} data from subgraph and merging datasets...`)
  let updated = 0
  let newAddresses = 0
  for (let i = 0;;i += 1000) {
    const query = getQuery(i)
    //'https://api.thegraph.com/subgraphs/name/zfogg/bao-master-farmer-xdai',
    const { data: xdai }: SubgraphResult = await axios.post(
      'https://api.thegraph.com/subgraphs/name/zfogg/bao-token-xdai',
      { query }
    )
    if (xdai.errors) break

    for (let j = 0; j < xdai.data.users.length; j++) {
      const account: SubgraphAccount = xdai.data.users[j]
      const index = mainnetAddresses.indexOf(account.id)

      if (index >= 0) {
        lockedBalances[index].amount = BigNumber
          .from(lockedBalances[index].amount)
          .add(account.amount)
          .toString()
        updated++
      } else {
        lockedBalances.push({
          address: account.id,
          amount: account.amount.toString()
        })
        newAddresses++
      }
    }
  }

  console.log(
    `${chalk.greenBright('Done!')} Updated balances for ${
      chalk.yellowBright(updated)
    } addresses and found ${chalk.yellowBright(newAddresses)} new addresses.`
  )

  lockedBalances = lockedBalances
  // ban three EOAs owned by Baoman from distribution.
    .filter((account) => {
      const isDev = account.address.toLowerCase() === WALLETS.baoDevelopment.toLowerCase()
      const isLiq = account.address.toLowerCase() === WALLETS.baoLiquidity.toLowerCase()
      const isCom = account.address.toLowerCase() === WALLETS.baoCommunity.toLowerCase()
      return !isDev && !isLiq && !isCom
    })

  lockedBalances = lockedBalances.sort((a: Account, b: Account): number => {
    return BigNumber.from(a.amount).gt(BigNumber.from(b.amount)) ? -1 : 1
  })

  fs.writeFileSync(SNAPSHOT_FILE, JSON.stringify(lockedBalances, null, 2))
  console.log(`${chalk.greenBright('Done!')} Results written to ${chalk.yellowBright('snapshot.json')}`)
}

const main = async () => {
  await takeSnapshot()
  console.log()
  await verifySnapshot()
}

main()
