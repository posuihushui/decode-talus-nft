"use client";

import { Transaction } from "@mysten/sui/transactions";
import { NETWORK } from "@/config/network";
import { useCallback } from "react";
import { useExecuteTransaction } from "./useExecuteTransaction";

export function useMintingActions() {
  const { executeTransaction } = useExecuteTransaction();

  const startMinting = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::start_minting`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
      ],
    });
    return executeTransaction(tx, "Public minting started");
  }, [executeTransaction]);

  const stopMinting = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::stop_minting`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
      ],
    });
    return executeTransaction(tx, "Public minting stopped");
  }, [executeTransaction]);

  const startTrading = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::start_trading`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.transferPolicyId),
        tx.object(NETWORK.transferPolicyCapId),
      ],
    });
    return executeTransaction(tx, "Trading enabled");
  }, [executeTransaction]);

  const mintAdmin = useCallback(async (amount: number, kioskId: string, kioskCapId: string) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::mint_tally_admin`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
        tx.pure.u64(amount),
        tx.object(NETWORK.transferPolicyId),
        tx.object(kioskId),
        tx.object(kioskCapId),
      ],
    });
    return executeTransaction(tx, `Admin minted ${amount} NFTs`);
  }, [executeTransaction]);

  return {
    startMinting,
    stopMinting,
    startTrading,
    mintAdmin,
  };
}
