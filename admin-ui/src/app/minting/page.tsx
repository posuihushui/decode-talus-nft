"use client";

import { useMintingActions } from "@/hooks/useMintingActions";
import { useRegistryData } from "@/hooks/useRegistryData";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { useState, useEffect } from "react";
import { Shield, Unlock, Loader2 } from "lucide-react";
import { WalletGuard } from "@/components/layout/WalletGuard";

export default function MintingPage() {
    const { startMinting, stopMinting, startTrading } = useMintingActions();
    const { registryData, isLoading, refetch } = useRegistryData();
    const [mintingEnabled, setMintingEnabled] = useState(false);
    const [isProcessing, setIsProcessing] = useState(false);

    useEffect(() => {
        if (registryData) {
            setMintingEnabled(registryData.canPublicMint);
        }
    }, [registryData]);

    const handleMintingToggle = async (checked: boolean) => {
        setIsProcessing(true);
        try {
            if (checked) {
                await startMinting();
            } else {
                await stopMinting();
            }
            setMintingEnabled(checked);
            refetch();
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    const handleEnableTrading = async () => {
        setIsProcessing(true);
        try {
            await startTrading();
            refetch();
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
                    <h2 className="text-3xl font-bold tracking-tight">Minting Controls</h2>
                    <p className="text-muted-foreground">Manage public minting and trading status.</p>
                </div>

                <div className="grid gap-6 md:grid-cols-2">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Public Minting</CardTitle>
                            <Shield className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="flex items-center justify-between pt-4">
                                <div>
                                    <div className="text-2xl font-bold">
                                        {mintingEnabled ? "Enabled" : "Disabled"}
                                    </div>
                                    <p className="text-xs text-muted-foreground">
                                        {mintingEnabled ? "Users can mint NFTs" : "Minting is paused"}
                                    </p>
                                </div>
                                <Switch
                                    checked={mintingEnabled}
                                    onCheckedChange={handleMintingToggle}
                                    disabled={isProcessing}
                                />
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Trading</CardTitle>
                            <Unlock className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="pt-4 space-y-4">
                                <div>
                                    <div className="text-2xl font-bold">Enable Trading</div>
                                    <p className="text-xs text-muted-foreground">
                                        Remove trade restrictions (irreversible)
                                    </p>
                                </div>
                                <Button
                                    onClick={handleEnableTrading}
                                    disabled={isProcessing}
                                    variant="destructive"
                                    className="w-full"
                                >
                                    {isProcessing ? "Processing..." : "Enable Trading"}
                                </Button>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </WalletGuard>
    );
}
