"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Ticket, Coins, Database, ShieldCheck, Menu } from "lucide-react";
import { cn } from "@/lib/utils";
import { ConnectButton } from "@mysten/dapp-kit";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { useState } from "react";

const items = [
    { title: "Overview", url: "/", icon: LayoutDashboard },
    { title: "Minting Controls", url: "/minting", icon: ShieldCheck },
    { title: "Admin Mint", url: "/admin-mint", icon: ShieldCheck },
    { title: "Tickets", url: "/tickets", icon: Ticket },
    { title: "Metadata", url: "/metadata", icon: Database },
    { title: "Treasury", url: "/treasury", icon: Coins },
];

export function Navbar() {
    const pathname = usePathname();
    const [isOpen, setIsOpen] = useState(false);

    return (
        <header className="fixed top-0 left-0 right-0 z-50 border-b border-zinc-200 dark:border-zinc-800 bg-white/80 dark:bg-zinc-950/80 backdrop-blur-sm">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex h-16 items-center justify-between">
                    <div className="flex items-center gap-8">
                        <Link href="/" className="flex items-center gap-2 font-bold text-xl tracking-tight">
                            <span className="bg-gradient-to-r from-indigo-500 to-purple-600 bg-clip-text text-transparent">
                                Talus Admin
                            </span>
                        </Link>

                        {/* Desktop Navigation */}
                        <nav className="hidden md:flex items-center gap-1">
                            {items.map((item) => (
                                <Link
                                    key={item.url}
                                    href={item.url}
                                    className={cn(
                                        "flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors",
                                        pathname === item.url
                                            ? "bg-zinc-100 text-zinc-900 dark:bg-zinc-800 dark:text-zinc-50"
                                            : "text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:text-zinc-50 dark:hover:bg-zinc-800"
                                    )}
                                >
                                    <item.icon className="w-4 h-4" />
                                    {item.title}
                                </Link>
                            ))}
                        </nav>
                    </div>

                    <div className="flex items-center gap-4">
                        <ConnectButton />

                        {/* Mobile Menu */}
                        <Sheet open={isOpen} onOpenChange={setIsOpen}>
                            <SheetTrigger asChild className="md:hidden">
                                <Button variant="ghost" size="icon">
                                    <Menu className="w-5 h-5" />
                                </Button>
                            </SheetTrigger>
                            <SheetContent side="left">
                                <div className="flex flex-col gap-4 mt-8">
                                    {items.map((item) => (
                                        <Link
                                            key={item.url}
                                            href={item.url}
                                            onClick={() => setIsOpen(false)}
                                            className={cn(
                                                "flex items-center gap-2 px-3 py-2 rounded-md text-sm font-medium transition-colors",
                                                pathname === item.url
                                                    ? "bg-zinc-100 text-zinc-900 dark:bg-zinc-800 dark:text-zinc-50"
                                                    : "text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:text-zinc-50 dark:hover:bg-zinc-800"
                                            )}
                                        >
                                            <item.icon className="w-4 h-4" />
                                            {item.title}
                                        </Link>
                                    ))}
                                </div>
                            </SheetContent>
                        </Sheet>
                    </div>
                </div>
            </div>
        </header>
    );
}
