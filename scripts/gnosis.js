import { ethers } from 'ethers'
import { EthersAdapter } from '@gnosis.pm/safe-core-sdk'

const web3Provider = // ...
const provider = new ethers.providers.Web3Provider(web3Provider)
const owner1 = provider.getSigner(0)

const ethAdapterOwner1 = new EthersAdapter({
  ethers,
  signer: owner1
})