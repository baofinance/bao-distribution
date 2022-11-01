import fs from 'fs'
import { MerkleTree } from 'merkletreejs'
import { ethers } from 'ethers'
import { Account } from './types'
import chalk from 'chalk'

// -------------------------------
// MERKLE ROOT GENERATION
// -------------------------------

const args = process.argv.slice(2)

const generateMerkleRoot = () => {
  const snapshot: Account[] =
    JSON.parse(fs.readFileSync(`${__dirname}/../snapshot.json`).toString())

  const leaves = snapshot.map(account => _keccakAbiEncode(account.address, account.amount))
  const tree = new MerkleTree(leaves, ethers.utils.keccak256, { sort: true })
  const root = tree.getRoot().toString('hex')
  console.log(`${chalk.greenBright('Merkle Root:')} 0x${root}`)

  console.log('-------------------------------------------------------------------------------')
  let account: Account
  if (args[0]) {
    account = snapshot.find((item) => {
      return item.address.toLowerCase() === args[0].toLowerCase()
    })
    if (!account) {
      throw new Error(`!! Account ${args[0]} not in snapshot.`)
    }
  } else {
    account = snapshot[1]
  }

  const leaf = _keccakAbiEncode(account.address, account.amount)
  const proof = tree.getHexProof(leaf)
  console.log(
    `${chalk.cyanBright('Proof of inclusion for address')} "${
      chalk.yellowBright(account.address)
    }": ${JSON.stringify(proof, null, 2)}`
  )

  console.log(`Is proof valid?: ${tree.verify(proof, leaf, root) ? chalk.greenBright('Yes') : chalk.red('No')}`) // should always be yes!
}

const _keccakAbiEncode = (a: string, n: string): string =>
  ethers.utils.keccak256(ethers.utils.solidityPack(['address', 'uint256'], [a, n]))

generateMerkleRoot()
