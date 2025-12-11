"use client";

import { Transaction } from "@mysten/sui/transactions";
import { NETWORK_CONFIG } from "@/config/network";
import { useCallback } from "react";
import { useExecuteTransaction } from "./useExecuteTransaction";

export function useTreasuryActions() {
  const { executeTransaction } = useExecuteTransaction();

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
        tx.object(NETWORK_CONFIG.testnet.transferPolicyCapId),
      ],
    });
    return executeTransaction(tx, "Royalties withdrawn");
  }, [executeTransaction]);

  return {
    withdrawBalance,
    withdrawRoyalties,
  };
}
