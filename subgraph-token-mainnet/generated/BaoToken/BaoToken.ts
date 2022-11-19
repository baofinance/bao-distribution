// THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.

import {
  ethereum,
  JSONValue,
  TypedMap,
  Entity,
  Bytes,
  Address,
  BigInt
} from "@graphprotocol/graph-ts";

export class Approval extends ethereum.Event {
  get params(): Approval__Params {
    return new Approval__Params(this);
  }
}

export class Approval__Params {
  _event: Approval;

  constructor(event: Approval) {
    this._event = event;
  }

  get owner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get spender(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get value(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class DelegateChanged extends ethereum.Event {
  get params(): DelegateChanged__Params {
    return new DelegateChanged__Params(this);
  }
}

export class DelegateChanged__Params {
  _event: DelegateChanged;

  constructor(event: DelegateChanged) {
    this._event = event;
  }

  get delegator(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get fromDelegate(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get toDelegate(): Address {
    return this._event.parameters[2].value.toAddress();
  }
}

export class DelegateVotesChanged extends ethereum.Event {
  get params(): DelegateVotesChanged__Params {
    return new DelegateVotesChanged__Params(this);
  }
}

export class DelegateVotesChanged__Params {
  _event: DelegateVotesChanged;

  constructor(event: DelegateVotesChanged) {
    this._event = event;
  }

  get delegate(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get previousBalance(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }

  get newBalance(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class Lock extends ethereum.Event {
  get params(): Lock__Params {
    return new Lock__Params(this);
  }
}

export class Lock__Params {
  _event: Lock;

  constructor(event: Lock) {
    this._event = event;
  }

  get to(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get value(): BigInt {
    return this._event.parameters[1].value.toBigInt();
  }
}

export class OwnershipTransferred extends ethereum.Event {
  get params(): OwnershipTransferred__Params {
    return new OwnershipTransferred__Params(this);
  }
}

export class OwnershipTransferred__Params {
  _event: OwnershipTransferred;

  constructor(event: OwnershipTransferred) {
    this._event = event;
  }

  get previousOwner(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get newOwner(): Address {
    return this._event.parameters[1].value.toAddress();
  }
}

export class Transfer extends ethereum.Event {
  get params(): Transfer__Params {
    return new Transfer__Params(this);
  }
}

export class Transfer__Params {
  _event: Transfer;

  constructor(event: Transfer) {
    this._event = event;
  }

  get from(): Address {
    return this._event.parameters[0].value.toAddress();
  }

  get to(): Address {
    return this._event.parameters[1].value.toAddress();
  }

  get value(): BigInt {
    return this._event.parameters[2].value.toBigInt();
  }
}

export class BaoToken__checkpointsResult {
  value0: BigInt;
  value1: BigInt;

  constructor(value0: BigInt, value1: BigInt) {
    this.value0 = value0;
    this.value1 = value1;
  }

  toMap(): TypedMap<string, ethereum.Value> {
    let map = new TypedMap<string, ethereum.Value>();
    map.set("value0", ethereum.Value.fromUnsignedBigInt(this.value0));
    map.set("value1", ethereum.Value.fromUnsignedBigInt(this.value1));
    return map;
  }

  getFromBlock(): BigInt {
    return this.value0;
  }

  getVotes(): BigInt {
    return this.value1;
  }
}

export class BaoToken extends ethereum.SmartContract {
  static bind(address: Address): BaoToken {
    return new BaoToken("BaoToken", address);
  }

  DELEGATION_TYPEHASH(): Bytes {
    let result = super.call(
      "DELEGATION_TYPEHASH",
      "DELEGATION_TYPEHASH():(bytes32)",
      []
    );

    return result[0].toBytes();
  }

  try_DELEGATION_TYPEHASH(): ethereum.CallResult<Bytes> {
    let result = super.tryCall(
      "DELEGATION_TYPEHASH",
      "DELEGATION_TYPEHASH():(bytes32)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBytes());
  }

  DOMAIN_TYPEHASH(): Bytes {
    let result = super.call(
      "DOMAIN_TYPEHASH",
      "DOMAIN_TYPEHASH():(bytes32)",
      []
    );

    return result[0].toBytes();
  }

  try_DOMAIN_TYPEHASH(): ethereum.CallResult<Bytes> {
    let result = super.tryCall(
      "DOMAIN_TYPEHASH",
      "DOMAIN_TYPEHASH():(bytes32)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBytes());
  }

  allowance(owner: Address, spender: Address): BigInt {
    let result = super.call(
      "allowance",
      "allowance(address,address):(uint256)",
      [ethereum.Value.fromAddress(owner), ethereum.Value.fromAddress(spender)]
    );

    return result[0].toBigInt();
  }

  try_allowance(owner: Address, spender: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "allowance",
      "allowance(address,address):(uint256)",
      [ethereum.Value.fromAddress(owner), ethereum.Value.fromAddress(spender)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  approve(spender: Address, amount: BigInt): boolean {
    let result = super.call("approve", "approve(address,uint256):(bool)", [
      ethereum.Value.fromAddress(spender),
      ethereum.Value.fromUnsignedBigInt(amount)
    ]);

    return result[0].toBoolean();
  }

  try_approve(spender: Address, amount: BigInt): ethereum.CallResult<boolean> {
    let result = super.tryCall("approve", "approve(address,uint256):(bool)", [
      ethereum.Value.fromAddress(spender),
      ethereum.Value.fromUnsignedBigInt(amount)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  authorized(param0: Address): boolean {
    let result = super.call("authorized", "authorized(address):(bool)", [
      ethereum.Value.fromAddress(param0)
    ]);

    return result[0].toBoolean();
  }

  try_authorized(param0: Address): ethereum.CallResult<boolean> {
    let result = super.tryCall("authorized", "authorized(address):(bool)", [
      ethereum.Value.fromAddress(param0)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  balanceOf(account: Address): BigInt {
    let result = super.call("balanceOf", "balanceOf(address):(uint256)", [
      ethereum.Value.fromAddress(account)
    ]);

    return result[0].toBigInt();
  }

  try_balanceOf(account: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall("balanceOf", "balanceOf(address):(uint256)", [
      ethereum.Value.fromAddress(account)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  canUnlockAmount(_holder: Address): BigInt {
    let result = super.call(
      "canUnlockAmount",
      "canUnlockAmount(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );

    return result[0].toBigInt();
  }

  try_canUnlockAmount(_holder: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "canUnlockAmount",
      "canUnlockAmount(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  cap(): BigInt {
    let result = super.call("cap", "cap():(uint256)", []);

    return result[0].toBigInt();
  }

  try_cap(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("cap", "cap():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  checkpoints(param0: Address, param1: BigInt): BaoToken__checkpointsResult {
    let result = super.call(
      "checkpoints",
      "checkpoints(address,uint32):(uint32,uint256)",
      [
        ethereum.Value.fromAddress(param0),
        ethereum.Value.fromUnsignedBigInt(param1)
      ]
    );

    return new BaoToken__checkpointsResult(
      result[0].toBigInt(),
      result[1].toBigInt()
    );
  }

  try_checkpoints(
    param0: Address,
    param1: BigInt
  ): ethereum.CallResult<BaoToken__checkpointsResult> {
    let result = super.tryCall(
      "checkpoints",
      "checkpoints(address,uint32):(uint32,uint256)",
      [
        ethereum.Value.fromAddress(param0),
        ethereum.Value.fromUnsignedBigInt(param1)
      ]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(
      new BaoToken__checkpointsResult(value[0].toBigInt(), value[1].toBigInt())
    );
  }

  circulatingSupply(): BigInt {
    let result = super.call(
      "circulatingSupply",
      "circulatingSupply():(uint256)",
      []
    );

    return result[0].toBigInt();
  }

  try_circulatingSupply(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "circulatingSupply",
      "circulatingSupply():(uint256)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  decimals(): i32 {
    let result = super.call("decimals", "decimals():(uint8)", []);

    return result[0].toI32();
  }

  try_decimals(): ethereum.CallResult<i32> {
    let result = super.tryCall("decimals", "decimals():(uint8)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toI32());
  }

  decreaseAllowance(spender: Address, subtractedValue: BigInt): boolean {
    let result = super.call(
      "decreaseAllowance",
      "decreaseAllowance(address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(spender),
        ethereum.Value.fromUnsignedBigInt(subtractedValue)
      ]
    );

    return result[0].toBoolean();
  }

  try_decreaseAllowance(
    spender: Address,
    subtractedValue: BigInt
  ): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "decreaseAllowance",
      "decreaseAllowance(address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(spender),
        ethereum.Value.fromUnsignedBigInt(subtractedValue)
      ]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  delegates(delegator: Address): Address {
    let result = super.call("delegates", "delegates(address):(address)", [
      ethereum.Value.fromAddress(delegator)
    ]);

    return result[0].toAddress();
  }

  try_delegates(delegator: Address): ethereum.CallResult<Address> {
    let result = super.tryCall("delegates", "delegates(address):(address)", [
      ethereum.Value.fromAddress(delegator)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  getCurrentVotes(account: Address): BigInt {
    let result = super.call(
      "getCurrentVotes",
      "getCurrentVotes(address):(uint256)",
      [ethereum.Value.fromAddress(account)]
    );

    return result[0].toBigInt();
  }

  try_getCurrentVotes(account: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "getCurrentVotes",
      "getCurrentVotes(address):(uint256)",
      [ethereum.Value.fromAddress(account)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  getPriorVotes(account: Address, blockNumber: BigInt): BigInt {
    let result = super.call(
      "getPriorVotes",
      "getPriorVotes(address,uint256):(uint256)",
      [
        ethereum.Value.fromAddress(account),
        ethereum.Value.fromUnsignedBigInt(blockNumber)
      ]
    );

    return result[0].toBigInt();
  }

  try_getPriorVotes(
    account: Address,
    blockNumber: BigInt
  ): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "getPriorVotes",
      "getPriorVotes(address,uint256):(uint256)",
      [
        ethereum.Value.fromAddress(account),
        ethereum.Value.fromUnsignedBigInt(blockNumber)
      ]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  increaseAllowance(spender: Address, addedValue: BigInt): boolean {
    let result = super.call(
      "increaseAllowance",
      "increaseAllowance(address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(spender),
        ethereum.Value.fromUnsignedBigInt(addedValue)
      ]
    );

    return result[0].toBoolean();
  }

  try_increaseAllowance(
    spender: Address,
    addedValue: BigInt
  ): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "increaseAllowance",
      "increaseAllowance(address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(spender),
        ethereum.Value.fromUnsignedBigInt(addedValue)
      ]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  lastUnlockBlock(_holder: Address): BigInt {
    let result = super.call(
      "lastUnlockBlock",
      "lastUnlockBlock(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );

    return result[0].toBigInt();
  }

  try_lastUnlockBlock(_holder: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "lastUnlockBlock",
      "lastUnlockBlock(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  lockFromBlock(): BigInt {
    let result = super.call("lockFromBlock", "lockFromBlock():(uint256)", []);

    return result[0].toBigInt();
  }

  try_lockFromBlock(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "lockFromBlock",
      "lockFromBlock():(uint256)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  lockOf(_holder: Address): BigInt {
    let result = super.call("lockOf", "lockOf(address):(uint256)", [
      ethereum.Value.fromAddress(_holder)
    ]);

    return result[0].toBigInt();
  }

  try_lockOf(_holder: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall("lockOf", "lockOf(address):(uint256)", [
      ethereum.Value.fromAddress(_holder)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  lockToBlock(): BigInt {
    let result = super.call("lockToBlock", "lockToBlock():(uint256)", []);

    return result[0].toBigInt();
  }

  try_lockToBlock(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("lockToBlock", "lockToBlock():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  lockedSupply(): BigInt {
    let result = super.call("lockedSupply", "lockedSupply():(uint256)", []);

    return result[0].toBigInt();
  }

  try_lockedSupply(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("lockedSupply", "lockedSupply():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  manualMintLimit(): BigInt {
    let result = super.call(
      "manualMintLimit",
      "manualMintLimit():(uint256)",
      []
    );

    return result[0].toBigInt();
  }

  try_manualMintLimit(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "manualMintLimit",
      "manualMintLimit():(uint256)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  manualMinted(): BigInt {
    let result = super.call("manualMinted", "manualMinted():(uint256)", []);

    return result[0].toBigInt();
  }

  try_manualMinted(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("manualMinted", "manualMinted():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  name(): string {
    let result = super.call("name", "name():(string)", []);

    return result[0].toString();
  }

  try_name(): ethereum.CallResult<string> {
    let result = super.tryCall("name", "name():(string)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toString());
  }

  nonces(param0: Address): BigInt {
    let result = super.call("nonces", "nonces(address):(uint256)", [
      ethereum.Value.fromAddress(param0)
    ]);

    return result[0].toBigInt();
  }

  try_nonces(param0: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall("nonces", "nonces(address):(uint256)", [
      ethereum.Value.fromAddress(param0)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  numCheckpoints(param0: Address): BigInt {
    let result = super.call(
      "numCheckpoints",
      "numCheckpoints(address):(uint32)",
      [ethereum.Value.fromAddress(param0)]
    );

    return result[0].toBigInt();
  }

  try_numCheckpoints(param0: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "numCheckpoints",
      "numCheckpoints(address):(uint32)",
      [ethereum.Value.fromAddress(param0)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  owner(): Address {
    let result = super.call("owner", "owner():(address)", []);

    return result[0].toAddress();
  }

  try_owner(): ethereum.CallResult<Address> {
    let result = super.tryCall("owner", "owner():(address)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  previousOwner(): Address {
    let result = super.call("previousOwner", "previousOwner():(address)", []);

    return result[0].toAddress();
  }

  try_previousOwner(): ethereum.CallResult<Address> {
    let result = super.tryCall(
      "previousOwner",
      "previousOwner():(address)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toAddress());
  }

  symbol(): string {
    let result = super.call("symbol", "symbol():(string)", []);

    return result[0].toString();
  }

  try_symbol(): ethereum.CallResult<string> {
    let result = super.tryCall("symbol", "symbol():(string)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toString());
  }

  totalBalanceOf(_holder: Address): BigInt {
    let result = super.call(
      "totalBalanceOf",
      "totalBalanceOf(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );

    return result[0].toBigInt();
  }

  try_totalBalanceOf(_holder: Address): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "totalBalanceOf",
      "totalBalanceOf(address):(uint256)",
      [ethereum.Value.fromAddress(_holder)]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  totalLock(): BigInt {
    let result = super.call("totalLock", "totalLock():(uint256)", []);

    return result[0].toBigInt();
  }

  try_totalLock(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("totalLock", "totalLock():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  totalSupply(): BigInt {
    let result = super.call("totalSupply", "totalSupply():(uint256)", []);

    return result[0].toBigInt();
  }

  try_totalSupply(): ethereum.CallResult<BigInt> {
    let result = super.tryCall("totalSupply", "totalSupply():(uint256)", []);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }

  transfer(recipient: Address, amount: BigInt): boolean {
    let result = super.call("transfer", "transfer(address,uint256):(bool)", [
      ethereum.Value.fromAddress(recipient),
      ethereum.Value.fromUnsignedBigInt(amount)
    ]);

    return result[0].toBoolean();
  }

  try_transfer(
    recipient: Address,
    amount: BigInt
  ): ethereum.CallResult<boolean> {
    let result = super.tryCall("transfer", "transfer(address,uint256):(bool)", [
      ethereum.Value.fromAddress(recipient),
      ethereum.Value.fromUnsignedBigInt(amount)
    ]);
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  transferFrom(sender: Address, recipient: Address, amount: BigInt): boolean {
    let result = super.call(
      "transferFrom",
      "transferFrom(address,address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(sender),
        ethereum.Value.fromAddress(recipient),
        ethereum.Value.fromUnsignedBigInt(amount)
      ]
    );

    return result[0].toBoolean();
  }

  try_transferFrom(
    sender: Address,
    recipient: Address,
    amount: BigInt
  ): ethereum.CallResult<boolean> {
    let result = super.tryCall(
      "transferFrom",
      "transferFrom(address,address,uint256):(bool)",
      [
        ethereum.Value.fromAddress(sender),
        ethereum.Value.fromAddress(recipient),
        ethereum.Value.fromUnsignedBigInt(amount)
      ]
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBoolean());
  }

  unlockedSupply(): BigInt {
    let result = super.call("unlockedSupply", "unlockedSupply():(uint256)", []);

    return result[0].toBigInt();
  }

  try_unlockedSupply(): ethereum.CallResult<BigInt> {
    let result = super.tryCall(
      "unlockedSupply",
      "unlockedSupply():(uint256)",
      []
    );
    if (result.reverted) {
      return new ethereum.CallResult();
    }
    let value = result.value;
    return ethereum.CallResult.fromValue(value[0].toBigInt());
  }
}

export class ConstructorCall extends ethereum.Call {
  get inputs(): ConstructorCall__Inputs {
    return new ConstructorCall__Inputs(this);
  }

  get outputs(): ConstructorCall__Outputs {
    return new ConstructorCall__Outputs(this);
  }
}

export class ConstructorCall__Inputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }

  get _lockFromBlock(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }

  get _lockToBlock(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class ConstructorCall__Outputs {
  _call: ConstructorCall;

  constructor(call: ConstructorCall) {
    this._call = call;
  }
}

export class AddAuthorizedCall extends ethereum.Call {
  get inputs(): AddAuthorizedCall__Inputs {
    return new AddAuthorizedCall__Inputs(this);
  }

  get outputs(): AddAuthorizedCall__Outputs {
    return new AddAuthorizedCall__Outputs(this);
  }
}

export class AddAuthorizedCall__Inputs {
  _call: AddAuthorizedCall;

  constructor(call: AddAuthorizedCall) {
    this._call = call;
  }

  get _toAdd(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class AddAuthorizedCall__Outputs {
  _call: AddAuthorizedCall;

  constructor(call: AddAuthorizedCall) {
    this._call = call;
  }
}

export class ApproveCall extends ethereum.Call {
  get inputs(): ApproveCall__Inputs {
    return new ApproveCall__Inputs(this);
  }

  get outputs(): ApproveCall__Outputs {
    return new ApproveCall__Outputs(this);
  }
}

export class ApproveCall__Inputs {
  _call: ApproveCall;

  constructor(call: ApproveCall) {
    this._call = call;
  }

  get spender(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class ApproveCall__Outputs {
  _call: ApproveCall;

  constructor(call: ApproveCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class CapUpdateCall extends ethereum.Call {
  get inputs(): CapUpdateCall__Inputs {
    return new CapUpdateCall__Inputs(this);
  }

  get outputs(): CapUpdateCall__Outputs {
    return new CapUpdateCall__Outputs(this);
  }
}

export class CapUpdateCall__Inputs {
  _call: CapUpdateCall;

  constructor(call: CapUpdateCall) {
    this._call = call;
  }

  get _newCap(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class CapUpdateCall__Outputs {
  _call: CapUpdateCall;

  constructor(call: CapUpdateCall) {
    this._call = call;
  }
}

export class DecreaseAllowanceCall extends ethereum.Call {
  get inputs(): DecreaseAllowanceCall__Inputs {
    return new DecreaseAllowanceCall__Inputs(this);
  }

  get outputs(): DecreaseAllowanceCall__Outputs {
    return new DecreaseAllowanceCall__Outputs(this);
  }
}

export class DecreaseAllowanceCall__Inputs {
  _call: DecreaseAllowanceCall;

  constructor(call: DecreaseAllowanceCall) {
    this._call = call;
  }

  get spender(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get subtractedValue(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class DecreaseAllowanceCall__Outputs {
  _call: DecreaseAllowanceCall;

  constructor(call: DecreaseAllowanceCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class DelegateCall extends ethereum.Call {
  get inputs(): DelegateCall__Inputs {
    return new DelegateCall__Inputs(this);
  }

  get outputs(): DelegateCall__Outputs {
    return new DelegateCall__Outputs(this);
  }
}

export class DelegateCall__Inputs {
  _call: DelegateCall;

  constructor(call: DelegateCall) {
    this._call = call;
  }

  get delegatee(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class DelegateCall__Outputs {
  _call: DelegateCall;

  constructor(call: DelegateCall) {
    this._call = call;
  }
}

export class DelegateBySigCall extends ethereum.Call {
  get inputs(): DelegateBySigCall__Inputs {
    return new DelegateBySigCall__Inputs(this);
  }

  get outputs(): DelegateBySigCall__Outputs {
    return new DelegateBySigCall__Outputs(this);
  }
}

export class DelegateBySigCall__Inputs {
  _call: DelegateBySigCall;

  constructor(call: DelegateBySigCall) {
    this._call = call;
  }

  get delegatee(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get nonce(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }

  get expiry(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }

  get v(): i32 {
    return this._call.inputValues[3].value.toI32();
  }

  get r(): Bytes {
    return this._call.inputValues[4].value.toBytes();
  }

  get s(): Bytes {
    return this._call.inputValues[5].value.toBytes();
  }
}

export class DelegateBySigCall__Outputs {
  _call: DelegateBySigCall;

  constructor(call: DelegateBySigCall) {
    this._call = call;
  }
}

export class IncreaseAllowanceCall extends ethereum.Call {
  get inputs(): IncreaseAllowanceCall__Inputs {
    return new IncreaseAllowanceCall__Inputs(this);
  }

  get outputs(): IncreaseAllowanceCall__Outputs {
    return new IncreaseAllowanceCall__Outputs(this);
  }
}

export class IncreaseAllowanceCall__Inputs {
  _call: IncreaseAllowanceCall;

  constructor(call: IncreaseAllowanceCall) {
    this._call = call;
  }

  get spender(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get addedValue(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class IncreaseAllowanceCall__Outputs {
  _call: IncreaseAllowanceCall;

  constructor(call: IncreaseAllowanceCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class LockCall extends ethereum.Call {
  get inputs(): LockCall__Inputs {
    return new LockCall__Inputs(this);
  }

  get outputs(): LockCall__Outputs {
    return new LockCall__Outputs(this);
  }
}

export class LockCall__Inputs {
  _call: LockCall;

  constructor(call: LockCall) {
    this._call = call;
  }

  get _holder(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class LockCall__Outputs {
  _call: LockCall;

  constructor(call: LockCall) {
    this._call = call;
  }
}

export class LockFromUpdateCall extends ethereum.Call {
  get inputs(): LockFromUpdateCall__Inputs {
    return new LockFromUpdateCall__Inputs(this);
  }

  get outputs(): LockFromUpdateCall__Outputs {
    return new LockFromUpdateCall__Outputs(this);
  }
}

export class LockFromUpdateCall__Inputs {
  _call: LockFromUpdateCall;

  constructor(call: LockFromUpdateCall) {
    this._call = call;
  }

  get _newLockFrom(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class LockFromUpdateCall__Outputs {
  _call: LockFromUpdateCall;

  constructor(call: LockFromUpdateCall) {
    this._call = call;
  }
}

export class LockToUpdateCall extends ethereum.Call {
  get inputs(): LockToUpdateCall__Inputs {
    return new LockToUpdateCall__Inputs(this);
  }

  get outputs(): LockToUpdateCall__Outputs {
    return new LockToUpdateCall__Outputs(this);
  }
}

export class LockToUpdateCall__Inputs {
  _call: LockToUpdateCall;

  constructor(call: LockToUpdateCall) {
    this._call = call;
  }

  get _newLockTo(): BigInt {
    return this._call.inputValues[0].value.toBigInt();
  }
}

export class LockToUpdateCall__Outputs {
  _call: LockToUpdateCall;

  constructor(call: LockToUpdateCall) {
    this._call = call;
  }
}

export class ManualMintCall extends ethereum.Call {
  get inputs(): ManualMintCall__Inputs {
    return new ManualMintCall__Inputs(this);
  }

  get outputs(): ManualMintCall__Outputs {
    return new ManualMintCall__Outputs(this);
  }
}

export class ManualMintCall__Inputs {
  _call: ManualMintCall;

  constructor(call: ManualMintCall) {
    this._call = call;
  }

  get _to(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class ManualMintCall__Outputs {
  _call: ManualMintCall;

  constructor(call: ManualMintCall) {
    this._call = call;
  }
}

export class MintCall extends ethereum.Call {
  get inputs(): MintCall__Inputs {
    return new MintCall__Inputs(this);
  }

  get outputs(): MintCall__Outputs {
    return new MintCall__Outputs(this);
  }
}

export class MintCall__Inputs {
  _call: MintCall;

  constructor(call: MintCall) {
    this._call = call;
  }

  get _to(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get _amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class MintCall__Outputs {
  _call: MintCall;

  constructor(call: MintCall) {
    this._call = call;
  }
}

export class ReclaimOwnershipCall extends ethereum.Call {
  get inputs(): ReclaimOwnershipCall__Inputs {
    return new ReclaimOwnershipCall__Inputs(this);
  }

  get outputs(): ReclaimOwnershipCall__Outputs {
    return new ReclaimOwnershipCall__Outputs(this);
  }
}

export class ReclaimOwnershipCall__Inputs {
  _call: ReclaimOwnershipCall;

  constructor(call: ReclaimOwnershipCall) {
    this._call = call;
  }

  get newOwner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class ReclaimOwnershipCall__Outputs {
  _call: ReclaimOwnershipCall;

  constructor(call: ReclaimOwnershipCall) {
    this._call = call;
  }
}

export class RemoveAuthorizedCall extends ethereum.Call {
  get inputs(): RemoveAuthorizedCall__Inputs {
    return new RemoveAuthorizedCall__Inputs(this);
  }

  get outputs(): RemoveAuthorizedCall__Outputs {
    return new RemoveAuthorizedCall__Outputs(this);
  }
}

export class RemoveAuthorizedCall__Inputs {
  _call: RemoveAuthorizedCall;

  constructor(call: RemoveAuthorizedCall) {
    this._call = call;
  }

  get _toRemove(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class RemoveAuthorizedCall__Outputs {
  _call: RemoveAuthorizedCall;

  constructor(call: RemoveAuthorizedCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall extends ethereum.Call {
  get inputs(): RenounceOwnershipCall__Inputs {
    return new RenounceOwnershipCall__Inputs(this);
  }

  get outputs(): RenounceOwnershipCall__Outputs {
    return new RenounceOwnershipCall__Outputs(this);
  }
}

export class RenounceOwnershipCall__Inputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class RenounceOwnershipCall__Outputs {
  _call: RenounceOwnershipCall;

  constructor(call: RenounceOwnershipCall) {
    this._call = call;
  }
}

export class TransferCall extends ethereum.Call {
  get inputs(): TransferCall__Inputs {
    return new TransferCall__Inputs(this);
  }

  get outputs(): TransferCall__Outputs {
    return new TransferCall__Outputs(this);
  }
}

export class TransferCall__Inputs {
  _call: TransferCall;

  constructor(call: TransferCall) {
    this._call = call;
  }

  get recipient(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[1].value.toBigInt();
  }
}

export class TransferCall__Outputs {
  _call: TransferCall;

  constructor(call: TransferCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class TransferAllCall extends ethereum.Call {
  get inputs(): TransferAllCall__Inputs {
    return new TransferAllCall__Inputs(this);
  }

  get outputs(): TransferAllCall__Outputs {
    return new TransferAllCall__Outputs(this);
  }
}

export class TransferAllCall__Inputs {
  _call: TransferAllCall;

  constructor(call: TransferAllCall) {
    this._call = call;
  }

  get _to(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class TransferAllCall__Outputs {
  _call: TransferAllCall;

  constructor(call: TransferAllCall) {
    this._call = call;
  }
}

export class TransferFromCall extends ethereum.Call {
  get inputs(): TransferFromCall__Inputs {
    return new TransferFromCall__Inputs(this);
  }

  get outputs(): TransferFromCall__Outputs {
    return new TransferFromCall__Outputs(this);
  }
}

export class TransferFromCall__Inputs {
  _call: TransferFromCall;

  constructor(call: TransferFromCall) {
    this._call = call;
  }

  get sender(): Address {
    return this._call.inputValues[0].value.toAddress();
  }

  get recipient(): Address {
    return this._call.inputValues[1].value.toAddress();
  }

  get amount(): BigInt {
    return this._call.inputValues[2].value.toBigInt();
  }
}

export class TransferFromCall__Outputs {
  _call: TransferFromCall;

  constructor(call: TransferFromCall) {
    this._call = call;
  }

  get value0(): boolean {
    return this._call.outputValues[0].value.toBoolean();
  }
}

export class TransferOwnershipCall extends ethereum.Call {
  get inputs(): TransferOwnershipCall__Inputs {
    return new TransferOwnershipCall__Inputs(this);
  }

  get outputs(): TransferOwnershipCall__Outputs {
    return new TransferOwnershipCall__Outputs(this);
  }
}

export class TransferOwnershipCall__Inputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }

  get newOwner(): Address {
    return this._call.inputValues[0].value.toAddress();
  }
}

export class TransferOwnershipCall__Outputs {
  _call: TransferOwnershipCall;

  constructor(call: TransferOwnershipCall) {
    this._call = call;
  }
}

export class UnlockCall extends ethereum.Call {
  get inputs(): UnlockCall__Inputs {
    return new UnlockCall__Inputs(this);
  }

  get outputs(): UnlockCall__Outputs {
    return new UnlockCall__Outputs(this);
  }
}

export class UnlockCall__Inputs {
  _call: UnlockCall;

  constructor(call: UnlockCall) {
    this._call = call;
  }
}

export class UnlockCall__Outputs {
  _call: UnlockCall;

  constructor(call: UnlockCall) {
    this._call = call;
  }
}