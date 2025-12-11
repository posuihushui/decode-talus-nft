"use client";

import { Transaction } from "@mysten/sui/transactions";
import { NETWORK } from "@/config/network";
import { useCallback } from "react";
import { useExecuteTransaction } from "./useExecuteTransaction";

export function useMetadataActions() {
  const { executeTransaction } = useExecuteTransaction();

  const addAttributes = useCallback(async (nftNumber: number, keys: string[], values: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::add_attributes`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.attributesId),
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
      target: `${NETWORK.packageId}::nft::bulk_add_attributes`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.attributesId),
        tx.pure.vector("u64", nftNumbers),
        tx.pure.vector("vector<string>", keysList),
        tx.pure.vector("vector<string>", valuesList),
      ],
    });
    return executeTransaction(tx, `Bulk added attributes for ${nftNumbers.length} NFTs`);
  }, [executeTransaction]);

  const addUrl = useCallback(async (nftNumber: number, url: string) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::add_url`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.attributesId),
        tx.pure.u64(nftNumber),
        tx.pure.string(url),
      ],
    });
    return executeTransaction(tx, `Added URL for NFT #${nftNumber}`);
  }, [executeTransaction]);

  const bulkAddUrls = useCallback(async (nftNumbers: number[], urls: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::bulk_add_urls`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.attributesId),
        tx.pure.vector("u64", nftNumbers),
        tx.pure.vector("string", urls),
      ],
    });
    return executeTransaction(tx, `Bulk added URLs for ${nftNumbers.length} NFTs`);
  }, [executeTransaction]);

  const startRevealing = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::start_revealing`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.attributesId),
      ],
    });
    return executeTransaction(tx, "Revealing started");
  }, [executeTransaction]);

  return {
    addAttributes,
    bulkAddAttributes,
    addUrl,
    bulkAddUrls,
    startRevealing,
  };
}
