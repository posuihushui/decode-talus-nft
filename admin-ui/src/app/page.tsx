"use client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useRegistryData } from "@/hooks/useRegistryData";
import { Loader2, TrendingUp, Users, Ticket, Coins } from "lucide-react";
import { Progress } from "@/components/ui/progress";

export default function OverviewPage() {
  const { registryData, isLoading } = useRegistryData();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="w-8 h-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  const mintProgress = registryData
    ? (registryData.minted / registryData.collectionSize) * 100
    : 0;

  const formatSui = (mist: number) => {
    return (mist / 1_000_000_000).toFixed(2);
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Dashboard</h2>
        <p className="text-muted-foreground">Overview of your NFT collection status.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Minted</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {registryData?.minted ?? "-"} / {registryData?.collectionSize ?? "-"}
            </div>
            <Progress value={mintProgress} className="mt-2" />
            <p className="text-xs text-muted-foreground mt-1">
              {mintProgress.toFixed(1)}% complete
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Minting Status</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {registryData?.canPublicMint ? (
                <span className="text-green-600">Active</span>
              ) : (
                <span className="text-red-600">Paused</span>
              )}
            </div>
            <p className="text-xs text-muted-foreground">
              Public mint price: {formatSui(registryData?.publicMintPrice ?? 0)} SUI
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Early Tickets</CardTitle>
            <Ticket className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{registryData?.earlyMints ?? 0}</div>
            <p className="text-xs text-muted-foreground">
              {registryData?.earlyMintsUsed ?? 0} used
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Free Tickets</CardTitle>
            <Coins className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{registryData?.freeMints ?? 0}</div>
            <p className="text-xs text-muted-foreground">
              {registryData?.freeMintsUsed ?? 0} used
            </p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Treasury Balance</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold">
            {formatSui(registryData?.balance ?? 0)} SUI
          </div>
          <p className="text-sm text-muted-foreground">
            Collected from minting fees
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
