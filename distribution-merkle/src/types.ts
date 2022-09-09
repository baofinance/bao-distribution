export type Account = {
  address: string
  amount: string
}

export type SubgraphAccount = {
  id: string
  amountOwed: string
}

export type SubgraphResult = {
  data: {
    data: {
      accounts: SubgraphAccount[]
    }
    errors?: any[]
  }
}