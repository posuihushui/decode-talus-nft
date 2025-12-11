"use client";

import { useMintingActions } from "@/hooks/useMintingActions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { useState } from "react";
import { ShieldAlert } from "lucide-react";
import { WalletGuard } from "@/components/layout/WalletGuard";

export default function AdminMintPage() {
    const { mintAdmin } = useMintingActions();
    const [amount, setAmount] = useState<string>("1");
    const [kioskId, setKioskId] = useState<string>("");
    const [kioskCapId, setKioskCapId] = useState<string>("");
    const [isProcessing, setIsProcessing] = useState(false);

    const handleMint = async () => {
        if (!amount || !kioskId || !kioskCapId) return;
        setIsProcessing(true);
        try {
            await mintAdmin(Number(amount), kioskId, kioskCapId);
            setAmount("1");
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <WalletGuard>
            <div className="space-y-6">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Admin Mint</h2>
                    <p className="text-muted-foreground">Mint NFTs directly to an admin Kiosk without payment.</p>
                </div>

                <div className="grid gap-6 md:grid-cols-2">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <ShieldAlert className="w-5 h-5" />
                                Mint Configuration
                            </CardTitle>
                            <CardDescription>
                                You must provide an existing Kiosk and Kiosk Owner Cap to receive the NFTs.
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Amount to Mint</label>
                                <Input
                                    type="number"
                                    value={amount}
                                    onChange={(e) => setAmount(e.target.value)}
                                    min="1"
                                    placeholder="1"
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Target Kiosk ID</label>
                                <Input
                                    value={kioskId}
                                    onChange={(e) => setKioskId(e.target.value)}
                                    placeholder="0x..."
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Kiosk Owner Cap ID</label>
                                <Input
                                    value={kioskCapId}
                                    onChange={(e) => setKioskCapId(e.target.value)}
                                    placeholder="0x..."
                                />
                            </div>
                            <Button onClick={handleMint} disabled={isProcessing || !kioskId || !kioskCapId} className="w-full">
                                {isProcessing ? "Minting..." : "Mint NFTs"}
                            </Button>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </WalletGuard>
    );
}
