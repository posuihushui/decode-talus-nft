"use client";

import { useCurrentAccount, ConnectButton } from "@mysten/dapp-kit";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Wallet } from "lucide-react";

export function WalletGuard({ children }: { children: React.ReactNode }) {
    const account = useCurrentAccount();

    if (!account) {
        return (
            <div className="flex items-center justify-center min-h-[60vh]">
                <Card className="w-full max-w-md text-center">
                    <CardHeader>
                        <div className="mx-auto bg-indigo-100 p-3 rounded-full mb-4 w-fit">
                            <Wallet className="w-6 h-6 text-indigo-600" />
                        </div>
                        <CardTitle>Connect Wallet</CardTitle>
                        <CardDescription>
                            You need to connect your wallet to access this dashboard feature.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="flex justify-center">
                            <ConnectButton />
                        </div>
                    </CardContent>
                </Card>
            </div>
        );
    }

    return <>{children}</>;
}
