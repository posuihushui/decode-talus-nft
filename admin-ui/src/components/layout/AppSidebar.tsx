"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Ticket, Coins, Database, ShieldCheck } from "lucide-react";
import { cn } from "@/lib/utils";
import { ConnectButton } from "@mysten/dapp-kit";

const items = [
    { title: "Overview", url: "/", icon: LayoutDashboard },
    { title: "Minting Controls", url: "/minting", icon: ShieldCheck },
    { title: "Admin Mint", url: "/admin-mint", icon: ShieldCheck },
    { title: "Tickets", url: "/tickets", icon: Ticket },
    { title: "Metadata", url: "/metadata", icon: Database },
    { title: "Treasury", url: "/treasury", icon: Coins },
];

export function AppSidebar() {
    const pathname = usePathname();

    return (
        <aside className="w-64 bg-white dark:bg-zinc-950 border-r border-zinc-200 dark:border-zinc-800 flex flex-col h-full bg-opacity-95 backdrop-blur-sm">
            <div className="p-6">
                <h1 className="text-xl font-bold tracking-tight bg-gradient-to-r from-indigo-500 to-purple-600 bg-clip-text text-transparent">
                    Talus Admin
                </h1>
            </div>
            <nav className="flex-1 px-4 space-y-2">
                {items.map((item) => (
                    <Link
                        key={item.url}
                        href={item.url}
                        className={cn(
                            "flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-all duration-200",
                            pathname === item.url
                                ? "bg-indigo-50 text-indigo-700 dark:bg-indigo-900/20 dark:text-indigo-300 shadow-sm"
                                : "text-zinc-500 hover:text-zinc-900 hover:bg-zinc-50 dark:text-zinc-400 dark:hover:text-zinc-50 dark:hover:bg-zinc-800/50"
                        )}
                    >
                        <item.icon className="w-4 h-4" />
                        {item.title}
                    </Link>
                ))}
            </nav>
            <div className="p-4 border-t border-zinc-200 dark:border-zinc-800">
                <ConnectButton className="w-full justify-center" />
            </div>
        </aside>
    );
}
