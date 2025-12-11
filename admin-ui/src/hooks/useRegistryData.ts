"use client";

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { NETWORK_CONFIG } from "@/config/network";

export interface RegistryData {
  minted: number;
  collectionSize: number;
  canPublicMint: boolean;
  balance: number;
  earlyMints: number;
  earlyMintsUsed: number;
  freeMints: number;
  freeMintsUsed: number;
  publicMintPrice: number;
  discountedMintPrice: number;
}

export function useRegistryData() {
  const { data, isLoading, error, refetch } = useSuiClientQuery(
    "getObject",
    {
      id: NETWORK_CONFIG.testnet.registryId,
      options: {
        showContent: true,
      },
    },
    {
      enabled: !!NETWORK_CONFIG.testnet.registryId,
    }
  );

  const parseRegistryData = (): RegistryData | null => {
    if (!data?.data?.content || data.data.content.dataType !== "moveObject") {
      return null;
    }

    const fields = data.data.content.fields as any;
    
    return {
      minted: Number(fields?.minted || 0),
      collectionSize: Number(fields?.collection_size || 0),
      canPublicMint: fields?.can_public_mint || false,
      balance: Number(fields?.balance || 0),
      earlyMints: Number(fields?.early_mints || 0),
      earlyMintsUsed: Number(fields?.early_mints_used || 0),
      freeMints: Number(fields?.free_mints || 0),
      freeMintsUsed: Number(fields?.free_mints_used || 0),
      publicMintPrice: Number(fields?.public_mint_price || 33000000000),
      discountedMintPrice: Number(fields?.discounted_mint_price || 5000000000),
    };
  };

  return {
    registryData: parseRegistryData(),
    isLoading,
    error,
    refetch,
  };
}
