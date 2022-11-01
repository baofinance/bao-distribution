import fs from 'fs'
import { MerkleTree } from 'merkletreejs'
import { ethers } from 'ethers'
import { Account } from './types'
import chalk from 'chalk'

// -------------------------------
// MERKLE ROOT GENERATION
// -------------------------------

const generateMerkleRoot = () => {
  const snapshot: Account[] =
    JSON.parse(fs.readFileSync(`${__dirname}/../snapshot.json`).toString())

  const leaves = snapshot.map(account => _keccakAbiEncode(account.address, account.amount))
  const tree = new MerkleTree(leaves, ethers.utils.keccak256, { sort: true })
  const root = tree.getRoot().toString('hex')
  console.log(`${chalk.greenBright('Merkle Root:')} 0x${root}`)

  console.log('-------------------------------------------------------------------------------')

  const leaf = _keccakAbiEncode(snapshot[1].address, snapshot[1].amount)
  const proof = tree.getHexProof(leaf)
  console.log(
    `${chalk.cyanBright('Sample proof of inclusion for address')} "${
      chalk.yellowBright(snapshot[1].address)
    }": ${JSON.stringify(proof)}`
  )
  console.log(`Is proof valid?: ${tree.verify(proof, leaf, root) ? chalk.greenBright('Yes') : chalk.red('No')}`) // should always be yes!
}

const _keccakAbiEncode = (a: string, n: string): string =>
  ethers.utils.keccak256(ethers.utils.solidityPack(['address', 'uint256'], [a, n]))

generateMerkleRoot()
