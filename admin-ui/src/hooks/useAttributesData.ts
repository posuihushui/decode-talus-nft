"use client";

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { NETWORK_CONFIG } from "@/config/network";

export interface AttributesData {
  canReveal: boolean;
}

export function useAttributesData() {
  const { data, isLoading, error, refetch } = useSuiClientQuery(
    "getObject",
    {
      id: NETWORK_CONFIG.testnet.attributesId,
      options: {
        showContent: true,
      },
    },
    {
      enabled: !!NETWORK_CONFIG.testnet.attributesId,
    }
  );

  const parseAttributesData = (): AttributesData | null => {
    if (!data?.data?.content || data.data.content.dataType !== "moveObject") {
      return null;
    }

    const fields = data.data.content.fields as any;
    
    return {
      canReveal: fields?.can_reveal || false,
    };
  };

  return {
    attributesData: parseAttributesData(),
    isLoading,
    error,
    refetch,
  };
}
