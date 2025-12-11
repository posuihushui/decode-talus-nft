"use client";

import { TicketDistributor } from "@/components/tickets/TicketDistributor";
import { useRegistryData } from "@/hooks/useRegistryData";
import { WalletGuard } from "@/components/layout/WalletGuard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Loader2, Ticket } from "lucide-react";

export default function TicketsPage() {
    const { registryData, isLoading, refetch } = useRegistryData();

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
                    <h2 className="text-3xl font-bold tracking-tight">Ticket Distribution</h2>
                    <p className="text-muted-foreground">Manage and distribute Early Access and Free Mint tickets.</p>
                </div>

                {/* Stats Cards */}
                <div className="grid gap-4 md:grid-cols-2">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Early Access Tickets</CardTitle>
                            <Ticket className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="text-2xl font-bold">{registryData?.earlyMints ?? 0}</div>
                            <p className="text-xs text-muted-foreground">
                                {registryData?.earlyMintsUsed ?? 0} used out of {registryData?.earlyMints ?? 0} distributed
                            </p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Free Tickets</CardTitle>
                            <Ticket className="h-4 w-4 text-muted-foreground" />
                        </CardHeader>
                        <CardContent>
                            <div className="text-2xl font-bold">{registryData?.freeMints ?? 0}</div>
                            <p className="text-xs text-muted-foreground">
                                {registryData?.freeMintsUsed ?? 0} used out of {registryData?.freeMints ?? 0} distributed
                            </p>
                        </CardContent>
                    </Card>
                </div>

                {/* Distribution Forms */}
                <div className="grid gap-6 md:grid-cols-2">
                    <TicketDistributor type="early" onSuccess={refetch} />
                    <TicketDistributor type="free" onSuccess={refetch} />
                </div>
            </div>
        </WalletGuard>
    );
}
