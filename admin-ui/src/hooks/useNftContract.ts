import { useCurrentAccount, useSignAndExecuteTransaction, useSuiClient } from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";
import { NETWORK_CONFIG } from "@/config/network";
import { toast } from "sonner";
import { useCallback } from "react";

export function useNftContract() {
  const client = useSuiClient();
  const account = useCurrentAccount();
  const { mutate: signAndExecute } = useSignAndExecuteTransaction({
    execute: async ({ bytes, signature }) =>
      await client.executeTransactionBlock({
        transactionBlock: bytes,
        signature,
        options: {
          showEffects: true,
          showObjectChanges: true,
        },
      }),
  });

  const executeTransaction = useCallback(
    (tx: Transaction, successMessage: string = "Transaction successful") => {
      return new Promise((resolve, reject) => {
        signAndExecute(
          {
            transaction: tx,
          },
          {
            onSuccess: (result) => {
              toast.success(successMessage, {
                description: `Digest: ${result.digest.slice(0, 10)}...`,
              });
              resolve(result);
            },
            onError: (error) => {
              toast.error("Transaction failed", {
                description: error.message,
              });
              reject(error);
            },
          }
        );
      });
    },
    [signAndExecute]
  );

  const startMinting = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::start_minting`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
      ],
    });
    return executeTransaction(tx, "Public minting started");
  }, [executeTransaction]);

  const stopMinting = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::stop_minting`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
      ],
    });
    return executeTransaction(tx, "Public minting stopped");
  }, [executeTransaction]);

  const startTrading = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::start_trading`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.transferPolicyId),
        tx.object(NETWORK_CONFIG.testnet.transferPolicyCapId || ""),
      ],
    });
    return executeTransaction(tx, "Trading started");
  }, [executeTransaction]);

  const distributeFreeTickets = useCallback(async (addresses: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::distribute_free_tickets`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
        tx.pure.vector("address", addresses),
      ],
    });
    return executeTransaction(tx, `Distributed ${addresses.length} free tickets`);
  }, [executeTransaction]);

  const distributeEarlyTickets = useCallback(async (addresses: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::distribute_early_tickets`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
        tx.pure.vector("address", addresses),
      ],
    });
    return executeTransaction(tx, `Distributed ${addresses.length} early access tickets`);
    return executeTransaction(tx, `Distributed ${addresses.length} early access tickets`);
  }, [executeTransaction]);

  const mintAdmin = useCallback(async (amount: number, kioskId: string, kioskCapId: string) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::mint_tally_admin`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
        tx.pure.u64(amount),
        tx.object(NETWORK_CONFIG.testnet.transferPolicyId),
        tx.object(kioskId),
        tx.object(kioskCapId),
      ],
    });
    return executeTransaction(tx, `Admin minted ${amount} NFTs`);
  }, [executeTransaction]);

  const addAttributes = useCallback(async (nftNumber: number, keys: string[], values: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::add_attributes`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.attributesId),
        tx.pure.u64(nftNumber),
        tx.pure.vector("string", keys),
        tx.pure.vector("string", values),
      ],
    });
    return executeTransaction(tx, `Added attributes for NFT #${nftNumber}`);
  }, [executeTransaction]);

   const bulkAddAttributes = useCallback(async (nftNumbers: number[], keysList: string[][], valuesList: string[][]) => {
    const tx = new Transaction();
    tx.moveCall({
        target: `${NETWORK_CONFIG.testnet.packageId}::nft::bulk_add_attributes`,
        arguments: [
            tx.object(NETWORK_CONFIG.testnet.adminCapId),
            tx.object(NETWORK_CONFIG.testnet.attributesId),
            tx.pure.vector("u64", nftNumbers),
            tx.pure.vector("vector<string>", keysList),
            tx.pure.vector("vector<string>", valuesList),
        ]
    });
    return executeTransaction(tx, `Bulk added attributes for ${nftNumbers.length} NFTs`);
   }, [executeTransaction]);

  const addUrl = useCallback(async (nftNumber: number, url: string) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::add_url`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.attributesId),
        tx.pure.u64(nftNumber),
        tx.pure.string(url),
      ],
    });
    return executeTransaction(tx, `Added URL for NFT #${nftNumber}`);
  }, [executeTransaction]);

  const bulkAddUrls = useCallback(async (nftNumbers: number[], urls: string[]) => {
      const tx = new Transaction();
      tx.moveCall({
          target: `${NETWORK_CONFIG.testnet.packageId}::nft::bulk_add_urls`,
          arguments: [
              tx.object(NETWORK_CONFIG.testnet.adminCapId),
              tx.object(NETWORK_CONFIG.testnet.attributesId),
              tx.pure.vector("u64", nftNumbers),
              tx.pure.vector("string", urls),
          ]
      });
      return executeTransaction(tx, `Bulk added URLs for ${nftNumbers.length} NFTs`);
  }, [executeTransaction]);

  const startRevealing = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::start_revealing`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.attributesId),
      ],
    });
    return executeTransaction(tx, "Revealing started");
  }, [executeTransaction]);

  const withdrawBalance = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::withdraw_balance`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.registryId),
      ],
    });
    return executeTransaction(tx, "Treasury balance withdrawn");
  }, [executeTransaction]);

  const withdrawRoyalties = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK_CONFIG.testnet.packageId}::nft::withdraw_royalties`,
      arguments: [
        tx.object(NETWORK_CONFIG.testnet.adminCapId),
        tx.object(NETWORK_CONFIG.testnet.transferPolicyId),
        tx.object(NETWORK_CONFIG.testnet.transferPolicyCapId || ""),
      ],
    });
    return executeTransaction(tx, "Royalties withdrawn");
  }, [executeTransaction]);

  return {
    startMinting,
    stopMinting,
    startTrading,
    mintAdmin,
    distributeFreeTickets,
    distributeEarlyTickets,
    addAttributes,
    bulkAddAttributes,
    addUrl,
    bulkAddUrls,
    startRevealing,
    withdrawBalance,
    withdrawRoyalties,
    executeTransaction, 
  };
}
