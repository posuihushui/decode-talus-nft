"use client";

import { Transaction } from "@mysten/sui/transactions";
import { NETWORK } from "@/config/network";
import { useCallback } from "react";
import { useExecuteTransaction } from "./useExecuteTransaction";

export function useTreasuryActions() {
  const { executeTransaction } = useExecuteTransaction();

  const withdrawBalance = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::withdraw_balance`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
      ],
    });
    return executeTransaction(tx, "Treasury balance withdrawn");
  }, [executeTransaction]);

  const withdrawRoyalties = useCallback(async () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::withdraw_royalties`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.transferPolicyId),
        tx.object(NETWORK.transferPolicyCapId),
      ],
    });
    return executeTransaction(tx, "Royalties withdrawn");
  }, [executeTransaction]);

  return {
    withdrawBalance,
    withdrawRoyalties,
  };
}
