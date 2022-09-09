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

// -------------------------------
// SNAPSHOT VERIFICATION
// -------------------------------

const verifySnapshot = async () => {
  console.log('Checking for duplicates and computing totals...')
  const snapshot: Account[] = JSON.parse(fs.readFileSync(SNAPSHOT_FILE).toString())

  const mainnetProvider = new ethers.providers.AlchemyProvider()
  const bao = new ethers.Contract('0x374CB8C27130E2c9E04F44303f3c8351B9De61C1', baoV1Abi, mainnetProvider)
  const xdaiProvider = new ethers.providers.JsonRpcProvider('https://rpc.gnosischain.com/')
  const baoCx = new ethers.Contract('0xe0d0b1DBbCF3dd5CAc67edaf9243863Fd70745DA', baoV1Abi, xdaiProvider)

  const mainnetLocked = await bao.lockedSupply()
  const xdaiLocked = await baoCx.lockedSupply()

  const exists = []
  let total = BigNumber.from(0)
  let newTotal = BigNumber.from(0)
  snapshot.forEach((account: Account) => {
    if (exists.includes(account.address)) console.log('DUPLICATE')
    total = total.add(BigNumber.from(account.amount))
    newTotal = newTotal.add(BigNumber.from(account.amount).div(1e4))
    exists.push(account.address)
  })

  console.log(chalk.greenBright('Done!'))
  console.log(`${chalk.cyanBright('Accounts:')} ${exists.length}`)
  console.log(`${chalk.cyanBright('Total locked BAO:')} ${total.toString()} or ${utils.formatUnits(total.toString())}`)
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
        accounts(skip:${i},first:1000) {
          id
          amountOwed
        }
      }
    `

  console.log(`Fetching ${chalk.blueBright('Mainnet')} data from subgraph...`)
  for (let i = 0;;i += 1000) {
    const query = getQuery(i)
    const { data: mainnet }: SubgraphResult = await axios.post(
      'https://api.thegraph.com/subgraphs/name/n0xmare/locked-bao-mainnet',
      { query }
    )
    if (mainnet.errors) break

    lockedBalances = lockedBalances.concat(
      mainnet.data.accounts.map((account: SubgraphAccount) => ({
        address: account.id,
        amount: account.amountOwed
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
    const { data: xdai }: SubgraphResult = await axios.post(
      'https://api.thegraph.com/subgraphs/name/n0xmare/locked-bao-xdai',
      { query }
    )
    if (xdai.errors) break

    for (let j = 0; j < xdai.data.accounts.length; j++) {
      const account: SubgraphAccount = xdai.data.accounts[j]
      const index = mainnetAddresses.indexOf(account.id)

      if (index >= 0) {
        lockedBalances[index].amount = BigNumber
          .from(lockedBalances[index].amount)
          .add(account.amountOwed)
          .toString()
        updated++
      } else {
        lockedBalances.push({
          address: account.id,
          amount: account.amountOwed.toString()
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