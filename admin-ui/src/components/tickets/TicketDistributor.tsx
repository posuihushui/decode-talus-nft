"use client";

import { useState } from "react";
import Papa from "papaparse";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Loader2, Upload } from "lucide-react";
import { toast } from "sonner";
import { useTicketActions } from "@/hooks/useTicketActions";

interface TicketDistributorProps {
    type: "free" | "early";
    onSuccess?: () => void;
}

export function TicketDistributor({ type, onSuccess }: TicketDistributorProps) {
    const { distributeFreeTickets, distributeEarlyTickets } = useTicketActions();
    const [inputMode, setInputMode] = useState<"manual" | "csv">("manual");
    const [manualInput, setManualInput] = useState("");
    const [parsedAddresses, setParsedAddresses] = useState<string[]>([]);
    const [isProcessing, setIsProcessing] = useState(false);

    const handleManualParse = () => {
        const addresses = manualInput
            .split(/[\n,]+/)
            .map((s) => s.trim())
            .filter((s) => s.startsWith("0x"));

        if (addresses.length === 0) {
            toast.error("No valid addresses found");
            return;
        }
        setParsedAddresses(addresses);
    };

    const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        Papa.parse(file, {
            complete: (results) => {
                const addresses: string[] = [];
                results.data.forEach((row: any) => {
                    // Assume address is in the first column or look for 0x string
                    const rowValues = Object.values(row);
                    const addr = rowValues.find((v: any) => typeof v === 'string' && v.trim().startsWith('0x'));
                    if (addr) addresses.push((addr as string).trim());
                });

                if (addresses.length === 0) {
                    toast.error("No valid addresses found in CSV");
                    return;
                }
                setParsedAddresses(addresses);
                toast.success(`Found ${addresses.length} addresses`);
            },
            header: false
        });
    };

    const handleDistribute = async () => {
        if (parsedAddresses.length === 0) return;
        setIsProcessing(true);
        try {
            // Chunk addresses if necessary (sui limit is usually high enough for ~500 but let's be safe or just send all for now)
            // For simplicity sending all. If list is huge -> should chunk.
            if (type === "free") {
                await distributeFreeTickets(parsedAddresses);
            } else {
                await distributeEarlyTickets(parsedAddresses);
            }
            setParsedAddresses([]);
            setManualInput("");
            onSuccess?.();
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <Card className="w-full">
            <CardHeader>
                <CardTitle className="capitalize">{type} Ticket Distribution</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
                <Tabs value={inputMode} onValueChange={(v) => setInputMode(v as any)}>
                    <TabsList className="grid w-full grid-cols-2">
                        <TabsTrigger value="manual">Manual Input</TabsTrigger>
                        <TabsTrigger value="csv">CSV Upload</TabsTrigger>
                    </TabsList>

                    <TabsContent value="manual" className="space-y-4">
                        <Textarea
                            placeholder="Paste addresses here (one per line or comma separated)..."
                            value={manualInput}
                            onChange={(e) => setManualInput(e.target.value)}
                            className="min-h-[150px] font-mono text-xs"
                        />
                        <Button onClick={handleManualParse} variant="secondary" className="w-full">
                            Parse Addresses
                        </Button>
                    </TabsContent>

                    <TabsContent value="csv" className="space-y-4">
                        <div className="flex flex-col items-center justify-center border-2 border-dashed border-zinc-200 dark:border-zinc-800 rounded-lg p-10 hover:bg-zinc-50 dark:hover:bg-zinc-900 transition-colors">
                            <Upload className="h-10 w-10 text-zinc-400 mb-4" />
                            <p className="text-sm text-zinc-500 mb-4">Upload a CSV file containing addresses</p>
                            <input
                                type="file"
                                accept=".csv"
                                className="hidden"
                                id={`csv-upload-${type}`}
                                onChange={handleFileUpload}
                            />
                            <Button asChild variant="outline">
                                <label htmlFor={`csv-upload-${type}`} className="cursor-pointer">Select File</label>
                            </Button>
                        </div>
                    </TabsContent>
                </Tabs>

                {parsedAddresses.length > 0 && (
                    <div className="space-y-4 border-t pt-4">
                        <div className="flex items-center justify-between">
                            <h4 className="text-sm font-medium">Preview ({parsedAddresses.length})</h4>
                            <Button onClick={() => setParsedAddresses([])} variant="ghost" size="sm" className="text-red-500 hover:text-red-600">
                                Clear
                            </Button>
                        </div>
                        <div className="max-h-[200px] overflow-y-auto rounded-md border text-xs">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead className="w-[50px]">#</TableHead>
                                        <TableHead>Address</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {parsedAddresses.map((addr, i) => (
                                        <TableRow key={i}>
                                            <TableCell>{i + 1}</TableCell>
                                            <TableCell className="font-mono">{addr}</TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                        <Button onClick={handleDistribute} disabled={isProcessing} className="w-full bg-indigo-600 hover:bg-indigo-700 text-white">
                            {isProcessing ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
                            Distribute {parsedAddresses.length} Tickets
                        </Button>
                    </div>
                )}
            </CardContent>
        </Card>
    );
}
