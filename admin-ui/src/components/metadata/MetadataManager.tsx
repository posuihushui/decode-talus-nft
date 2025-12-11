"use client";

import { useState } from "react";
import Papa from "papaparse";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Loader2, Upload, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";
import { useMetadataActions } from "@/hooks/useMetadataActions";
import { useAttributesData } from "@/hooks/useAttributesData";

export function MetadataManager() {
    const { addAttributes, bulkAddAttributes, addUrl, bulkAddUrls, startRevealing } = useMetadataActions();
    const { attributesData, refetch } = useAttributesData();
    const [isProcessing, setIsProcessing] = useState(false);

    // Single Attribute State
    const [nftId, setNftId] = useState("");
    const [attributes, setAttributes] = useState<{ key: string; value: string }[]>([{ key: "", value: "" }]);

    // Bulk Attribute State
    const [bulkAttributes, setBulkAttributes] = useState<{ id: string; keys: string[]; values: string[] }[]>([]);

    // Single URL State
    const [urlNftId, setUrlNftId] = useState("");
    const [url, setUrl] = useState("");

    // Bulk URL State
    const [bulkUrls, setBulkUrls] = useState<{ id: string; url: string }[]>([]);

    const handleAddAttributeField = () => {
        setAttributes([...attributes, { key: "", value: "" }]);
    };

    const handleRemoveAttributeField = (index: number) => {
        setAttributes(attributes.filter((_, i) => i !== index));
    };

    const handleAttributeChange = (index: number, field: "key" | "value", value: string) => {
        const newAttributes = [...attributes];
        newAttributes[index][field] = value;
        setAttributes(newAttributes);
    };

    const handleSubmitSingleAttributes = async () => {
        if (!nftId || attributes.length === 0) return;
        setIsProcessing(true);
        try {
            const keys = attributes.map(a => a.key);
            const values = attributes.map(a => a.value);
            await addAttributes(Number(nftId), keys, values);
            setNftId("");
            setAttributes([{ key: "", value: "" }]);
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    const handleBulkAttributeUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        Papa.parse(file, {
            header: true,
            complete: (results) => {
                // Expected CSV format: nft_number, key1, value1, key2, value2... OR nft_number, trait_type, value
                // Let's assume a simpler format: ID, Key, Value
                // Or a "wide" format where columns are keys? Wide format is better for bulk.
                // format: id, Background, Eyes, Mouth...
                const parsed: { id: string; keys: string[]; values: string[] }[] = [];

                results.data.forEach((row: any) => {
                    if (!row.id) return; // ID column is mandatory
                    const id = row.id;
                    const keys: string[] = [];
                    const values: string[] = [];

                    Object.keys(row).forEach(header => {
                        if (header !== 'id' && row[header]) {
                            keys.push(header);
                            values.push(row[header]);
                        }
                    });
                    if (keys.length > 0) {
                        parsed.push({ id, keys, values });
                    }
                });
                setBulkAttributes(parsed);
                toast.success(`Parsed attributes for ${parsed.length} NFTs`);
            }
        });
    };

    const handleSubmitBulkAttributes = async () => {
        if (bulkAttributes.length === 0) return;
        setIsProcessing(true);
        try {
            // Flatten for API: array of IDs, array of Keys lists, array of Values lists
            const ids = bulkAttributes.map(b => Number(b.id));
            const keysList = bulkAttributes.map(b => b.keys);
            const valuesList = bulkAttributes.map(b => b.values);
            await bulkAddAttributes(ids, keysList, valuesList);
            setBulkAttributes([]);
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    const handleSubmitSingleUrl = async () => {
        if (!urlNftId || !url) return;
        setIsProcessing(true);
        try {
            await addUrl(Number(urlNftId), url);
            setUrlNftId("");
            setUrl("");
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    const handleBulkUrlUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        Papa.parse(file, {
            header: false,
            complete: (results) => {
                // Expected CSV: ID, URL
                const parsed: { id: string; url: string }[] = [];
                results.data.forEach((row: any) => {
                    if (row[0] && row[1]) {
                        parsed.push({ id: row[0], url: row[1] });
                    }
                });
                setBulkUrls(parsed);
                toast.success(`Parsed URLs for ${parsed.length} NFTs`);
            }
        });
    };

    const handleSubmitBulkUrls = async () => {
        if (bulkUrls.length === 0) return;
        setIsProcessing(true);
        try {
            const ids = bulkUrls.map(u => Number(u.id));
            const urls = bulkUrls.map(u => u.url);
            await bulkAddUrls(ids, urls);
            setBulkUrls([]);
        } catch (e) {
            console.error(e);
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <div className="space-y-6">
            <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                    <div>
                        <CardTitle>Reveal Status</CardTitle>
                        <p className="text-sm text-muted-foreground mt-1">
                            Current: {attributesData?.canReveal ? (
                                <span className="text-green-600 font-medium">Enabled</span>
                            ) : (
                                <span className="text-yellow-600 font-medium">Disabled</span>
                            )}
                        </p>
                    </div>
                    <Button
                        onClick={async () => { await startRevealing(); refetch(); }}
                        disabled={isProcessing || attributesData?.canReveal}
                        variant="destructive"
                    >
                        {attributesData?.canReveal ? "Already Enabled" : "Enable Revealing"}
                    </Button>
                </CardHeader>
            </Card>

            <Tabs defaultValue="attributes">
                <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="attributes">Attributes</TabsTrigger>
                    <TabsTrigger value="urls">URLs</TabsTrigger>
                </TabsList>

                <TabsContent value="attributes" className="space-y-6">
                    <Card>
                        <CardHeader><CardTitle>Single Entry</CardTitle></CardHeader>
                        <CardContent className="space-y-4">
                            <div className="flex gap-4">
                                <Input placeholder="NFT ID" value={nftId} onChange={e => setNftId(e.target.value)} className="w-32" type="number" />
                            </div>
                            {attributes.map((attr, i) => (
                                <div key={i} className="flex gap-4">
                                    <Input placeholder="Trait Type" value={attr.key} onChange={e => handleAttributeChange(i, "key", e.target.value)} />
                                    <Input placeholder="Value" value={attr.value} onChange={e => handleAttributeChange(i, "value", e.target.value)} />
                                    <Button variant="ghost" size="icon" onClick={() => handleRemoveAttributeField(i)}><Trash2 className="w-4 h-4 text-red-500" /></Button>
                                </div>
                            ))}
                            <Button variant="outline" size="sm" onClick={handleAddAttributeField}><Plus className="w-4 h-4 mr-2" /> Add Trait</Button>
                            <Button onClick={handleSubmitSingleAttributes} disabled={isProcessing} className="w-full">Save Attributes</Button>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader><CardTitle>Bulk Upload (CSV)</CardTitle></CardHeader>
                        <CardContent className="space-y-4">
                            <div className="border-2 border-dashed border-zinc-200 dark:border-zinc-800 rounded-lg p-10 flex flex-col items-center justify-center">
                                <p className="mb-4 text-sm text-muted-foreground">Format: id, trait1, trait2...</p>
                                <Input type="file" accept=".csv" onChange={handleBulkAttributeUpload} className="w-full max-w-xs" />
                            </div>
                            {bulkAttributes.length > 0 && (
                                <Button onClick={handleSubmitBulkAttributes} disabled={isProcessing} className="w-full">
                                    Upload {bulkAttributes.length} Metadata Entries
                                </Button>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                <TabsContent value="urls" className="space-y-6">
                    <Card>
                        <CardHeader><CardTitle>Single URL</CardTitle></CardHeader>
                        <CardContent className="space-y-4">
                            <div className="flex gap-4">
                                <Input placeholder="NFT ID" value={urlNftId} onChange={e => setUrlNftId(e.target.value)} className="w-32" type="number" />
                                <Input placeholder="Image/Metadata URL" value={url} onChange={e => setUrl(e.target.value)} className="flex-1" />
                            </div>
                            <Button onClick={handleSubmitSingleUrl} disabled={isProcessing} className="w-full">Save URL</Button>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader><CardTitle>Bulk URL Upload (CSV)</CardTitle></CardHeader>
                        <CardContent className="space-y-4">
                            <div className="border-2 border-dashed border-zinc-200 dark:border-zinc-800 rounded-lg p-10 flex flex-col items-center justify-center">
                                <p className="mb-4 text-sm text-muted-foreground">Format: id, url</p>
                                <Input type="file" accept=".csv" onChange={handleBulkUrlUpload} className="w-full max-w-xs" />
                            </div>
                            {bulkUrls.length > 0 && (
                                <Button onClick={handleSubmitBulkUrls} disabled={isProcessing} className="w-full">
                                    Upload {bulkUrls.length} URLs
                                </Button>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </div>
    );
}
