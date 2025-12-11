
## decode talus nft contract from Move bytecode v7

source:
```
https://suiscan.xyz/mainnet/object/0x75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423/contracts
```




## others

### KIOSK

source:
```
https://suiscan.xyz/mainnet/object/0x434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879/contracts
https://github.com/MystenLabs/apps/tree/main/kiosk
```

### get tx info
testnet
source:
```bash
sui client tx-block 6rhTj1TUgaYGvs661Pht8fHEyLDBwR2JTSefxQjJuonP --json  | clip.exe
```

mainnet
```bash
# use packageId
 sui client object 0x75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423

# get tx degist from above command `8K4npPMS4s6hXoyPPmhBYh2eVZ5SQX831W3gHz9JYzmN`
sui client tx-block 8K4npPMS4s6hXoyPPmhBYh2eVZ5SQX831W3gHz9JYzmN --json  | clip.exe
```

```bash
# get prevTx from above command
sui client object 0x75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423 | grep prevTx

```