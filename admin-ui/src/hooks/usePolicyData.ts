"use client";

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { NETWORK } from "@/config/network";

export interface PolicyData {
  royaltyBalance: number;
}

export function usePolicyData() {
  const { data, isLoading, error, refetch } = useSuiClientQuery(
    "getObject",
    {
      id: NETWORK.transferPolicyId,
      options: {
        showContent: true,
      },
    },
    {
      enabled: !!NETWORK.transferPolicyId,
    }
  );

  const parsePolicyData = (): PolicyData | null => {
    if (!data?.data?.content || data.data.content.dataType !== "moveObject") {
      return null;
    }

    const fields = data.data.content.fields as any;
    
    return {
      royaltyBalance: Number(fields?.balance || 0),
    };
  };

  return {
    policyData: parsePolicyData(),
    isLoading,
    error,
    refetch,
  };
}
