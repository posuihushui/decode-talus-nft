"use client";

import { MetadataManager } from "@/components/metadata/MetadataManager";
import { WalletGuard } from "@/components/layout/WalletGuard";

export default function MetadataPage() {
    return (
        <WalletGuard>
            <div className="space-y-6">
                <div>
                    <h2 className="text-3xl font-bold tracking-tight">Metadata Management</h2>
                    <p className="text-muted-foreground">Manage NFT attributes, URLs, and reveal status.</p>
                </div>
                <MetadataManager />
            </div>
        </WalletGuard>
    );
}
