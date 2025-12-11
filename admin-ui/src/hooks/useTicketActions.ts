"use client";

import { Transaction } from "@mysten/sui/transactions";
import { NETWORK } from "@/config/network";
import { useCallback } from "react";
import { useExecuteTransaction } from "./useExecuteTransaction";

export function useTicketActions() {
  const { executeTransaction } = useExecuteTransaction();

  const distributeFreeTickets = useCallback(async (addresses: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::distribute_free_tickets`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
        tx.pure.vector("address", addresses),
      ],
    });
    return executeTransaction(tx, `Distributed ${addresses.length} free tickets`);
  }, [executeTransaction]);

  const distributeEarlyTickets = useCallback(async (addresses: string[]) => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${NETWORK.packageId}::nft::distribute_early_tickets`,
      arguments: [
        tx.object(NETWORK.adminCapId),
        tx.object(NETWORK.registryId),
        tx.pure.vector("address", addresses),
      ],
    });
    return executeTransaction(tx, `Distributed ${addresses.length} early access tickets`);
  }, [executeTransaction]);

  return {
    distributeFreeTickets,
    distributeEarlyTickets,
  };
}
