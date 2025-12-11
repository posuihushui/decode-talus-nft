"use client";

import { useTreasuryActions } from "@/hooks/useTreasuryActions";
import { useRegistryData } from "@/hooks/useRegistryData";
import { usePolicyData } from "@/hooks/usePolicyData";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Coins, PiggyBank, Loader2 } from "lucide-react";
import { WalletGuard } from "@/components/layout/WalletGuard";
import { useState } from "react";

export default function TreasuryPage() {
    const { withdrawBalance, withdrawRoyalties } = useTreasuryActions();
    const { registryData, isLoading: registryLoading, refetch: refetchRegistry } = useRegistryData();
    const { policyData, isLoading: policyLoading, refetch: refetchPolicy } = usePolicyData();
    const [isProcessing, setIsProcessing] = useState(false);

    const isLoading = registryLoading || policyLoading;

    const formatSui = (mist: number) => {
        return (mist / 1_000_000_000).toFixed(4);
    };

    const handleWithdrawBalance = async () => {
        setIsProcessing(true);
        try {
            await withdrawBalance();
            refetchRegistry();
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    const handleWithdrawRoyalties = async () => {
        setIsProcessing(true);
        try {
            await withdrawRoyalties();
            refetchPolicy();
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center min-h-[60vh]">
                <Loader2 className="w-8 h-8 animate-spin text-muted-foreground" />
            </div>
        );
    }

    return (
        <WalletGuard>
            <div className="space-y-6">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Treasury Management</h2>
                    <p className="text-muted-foreground">Withdraw collected mint fees and royalties.</p>
                </div>

                <div className="grid gap-6 md:grid-cols-2">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Mint Fees</CardTitle>
                            <Coins className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="pt-4 space-y-4">
                                <div>
                                    <div className="text-2xl font-bold">
                                        {formatSui(registryData?.balance ?? 0)} SUI
                                    </div>
                                    <p className="text-xs text-muted-foreground">
                                        Funds collected from initial mints.
                                    </p>
                                </div>
                                <Button
                                    onClick={handleWithdrawBalance}
                                    className="w-full"
                                    disabled={isProcessing || (registryData?.balance ?? 0) === 0}
                                >
                                    {isProcessing ? "Processing..." : "Withdraw Balance"}
                                </Button>
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Royalties</CardTitle>
                            <PiggyBank className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="pt-4 space-y-4">
                                <div>
                                    <div className="text-2xl font-bold">
                                        {formatSui(policyData?.royaltyBalance ?? 0)} SUI
                                    </div>
                                    <p className="text-xs text-muted-foreground">
                                        Funds collected from secondary sales.
                                    </p>
                                </div>
                                <Button
                                    onClick={handleWithdrawRoyalties}
                                    className="w-full"
                                    variant="secondary"
                                    disabled={isProcessing || (policyData?.royaltyBalance ?? 0) === 0}
                                >
                                    {isProcessing ? "Processing..." : "Withdraw Royalties"}
                                </Button>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </WalletGuard>
    );
}
