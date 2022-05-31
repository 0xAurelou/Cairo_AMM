# Create2
Create 2 function in Cairo

##Token Address:

-Eth
  slot : 0
  name in felt : 4543560
  address in felt : 6542

-Btc
  slot : 1
  name in felt : 4346947
  address in felt : 8785

-Bnb
  slot : 2
  name in felt : 4345410
  address in felt : 1332


##Things to investigate:
Like Create2

``
This version introduces a change to the way contract addresses are calculated. The address is a Pedersen hash on the caller address, a salt (random or chosen by the deployer), the contract code hash, and the hash of the constructor arguments, all appended by a prefix.``

```Hash(PREFIX, caller_address, salt, contract_hash, ctr_args_hash)```
