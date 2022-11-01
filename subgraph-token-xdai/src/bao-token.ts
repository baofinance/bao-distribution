import { BigInt } from "@graphprotocol/graph-ts"
import {
  BaoToken,
  Lock,
} from "../generated/BaoToken/BaoToken"
import { User } from "../generated/schema"

export function handleLock(event: Lock): void {
  // Entities can be loaded from the store using a string ID; this ID
  // needs to be unique across all entities of the same type
  let user = User.load(event.params.to.toHex())

  // Entities only exist after they have been saved to the store;
  // `null` checks allow to create entities on demand
  if (!user) {
    user = new User(event.params.to.toHex())

    // Entity fields can be set using simple assignments
    user.amount = BigInt.fromI32(0)
    user.address = event.params.to
  }

  // BigInt and BigDecimal math are supported
  user.amount = user.amount.plus(event.params.value)

  // Entities can be written to the store with `.save()`
  user.save()

  // Note: If a handler doesn't require existing field values, it is faster
  // _not_ to load the entity from the store. Instead, create it fresh with
  // `new Entity(...)`, set the fields that should be updated and save the
  // entity back to the store. Fields that were not set or unset remain
  // unchanged, allowing for partial updates to be applied.

  // It is also possible to access smart contracts from mappings. For
  // example, the contract that has emitted the event can be connected to
  // with:
  //
  // let contract = Contract.bind(event.address)
  //
  // The following functions can then be called on this contract to access
  // state variables and other data:
  //
  // - contract.DELEGATION_TYPEHASH(...)
  // - contract.DOMAIN_TYPEHASH(...)
  // - contract.allowance(...)
  // - contract.approve(...)
  // - contract.authorized(...)
  // - contract.balanceOf(...)
  // - contract.canUnlockAmount(...)
  // - contract.cap(...)
  // - contract.checkpoints(...)
  // - contract.circulatingSupply(...)
  // - contract.decimals(...)
  // - contract.decreaseAllowance(...)
  // - contract.delegates(...)
  // - contract.getCurrentVotes(...)
  // - contract.getPriorVotes(...)
  // - contract.increaseAllowance(...)
  // - contract.lastUnlockBlock(...)
  // - contract.lockFromBlock(...)
  // - contract.lockOf(...)
  // - contract.lockToBlock(...)
  // - contract.lockedSupply(...)
  // - contract.manualMintLimit(...)
  // - contract.manualMinted(...)
  // - contract.name(...)
  // - contract.nonces(...)
  // - contract.numCheckpoints(...)
  // - contract.owner(...)
  // - contract.previousOwner(...)
  // - contract.symbol(...)
  // - contract.totalBalanceOf(...)
  // - contract.totalLock(...)
  // - contract.totalSupply(...)
  // - contract.transfer(...)
  // - contract.transferFrom(...)
  // - contract.unlockedSupply(...)
}
