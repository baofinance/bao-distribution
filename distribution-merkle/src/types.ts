export type Account = {
  address: string
  amount: string
}

export type SubgraphAccount = {
  id: string
  address: string
  amount: string
}

export type SubgraphResult = {
  data: {
    data: {
      users: SubgraphAccount[]
    }
    errors?: any[]
  }
}
