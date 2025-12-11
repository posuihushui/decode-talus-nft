"use client";

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { NETWORK } from "@/config/network";

export interface AttributesData {
  canReveal: boolean;
}

export function useAttributesData() {
  const { data, isLoading, error, refetch } = useSuiClientQuery(
    "getObject",
    {
      id: NETWORK.attributesId,
      options: {
        showContent: true,
      },
    },
    {
      enabled: !!NETWORK.attributesId,
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
