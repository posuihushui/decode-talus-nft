"use client";

import { useSignAndExecuteTransaction, useSuiClient } from "@mysten/dapp-kit";
import { Transaction } from "@mysten/sui/transactions";
import { toast } from "sonner";
import { useCallback } from "react";

export function useExecuteTransaction() {
  const client = useSuiClient();
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

  return { executeTransaction };
}
