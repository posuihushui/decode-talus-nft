"use client";

import { useState, useMemo } from "react";
import Papa from "papaparse";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Loader2, Upload, Plus, Trash2, AlertCircle } from "lucide-react";
import { toast } from "sonner";
import { useMetadataActions } from "@/hooks/useMetadataActions";
import { useAttributesData } from "@/hooks/useAttributesData";

// Validation helpers
const isValidNftId = (id: string): boolean => {
    const num = Number(id);
    return !isNaN(num) && num >= 0 && Number.isInteger(num);
};

const isValidUrl = (url: string): boolean => {
    try {
        new URL(url);
        return true;
    } catch {
        return url.startsWith("ipfs://") || url.startsWith("ar://");
    }
};

const isValidTraitKey = (key: string): boolean => {
    return key.trim().length > 0 && key.length <= 64;
};

const isValidTraitValue = (value: string): boolean => {
    return value.trim().length > 0 && value.length <= 256;
};

interface ValidationError {
    field: string;
    message: string;
}

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

    // Validation for single attributes
    const attributeValidation = useMemo((): ValidationError[] => {
        const errors: ValidationError[] = [];

        if (nftId && !isValidNftId(nftId)) {
            errors.push({ field: "nftId", message: "NFT ID must be a non-negative integer" });
        }

        attributes.forEach((attr, i) => {
            if (attr.key && !isValidTraitKey(attr.key)) {
                errors.push({ field: `trait-key-${i}`, message: `Trait ${i + 1} key must be 1-64 characters` });
            }
            if (attr.value && !isValidTraitValue(attr.value)) {
                errors.push({ field: `trait-value-${i}`, message: `Trait ${i + 1} value must be 1-256 characters` });
            }
        });

        return errors;
    }, [nftId, attributes]);

    // Validation for single URL
    const urlValidation = useMemo((): ValidationError[] => {
        const errors: ValidationError[] = [];

        if (urlNftId && !isValidNftId(urlNftId)) {
            errors.push({ field: "urlNftId", message: "NFT ID must be a non-negative integer" });
        }

        if (url && !isValidUrl(url)) {
            errors.push({ field: "url", message: "Invalid URL format (must be http://, https://, ipfs://, or ar://)" });
        }

        return errors;
    }, [urlNftId, url]);

    const canSubmitAttributes = useMemo(() => {
        return nftId &&
            isValidNftId(nftId) &&
            attributes.some(a => a.key && a.value) &&
            attributes.every(a => (!a.key && !a.value) || (isValidTraitKey(a.key) && isValidTraitValue(a.value)));
    }, [nftId, attributes]);

    const canSubmitUrl = useMemo(() => {
        return urlNftId &&
            url &&
            isValidNftId(urlNftId) &&
            isValidUrl(url);
    }, [urlNftId, url]);

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
        if (!canSubmitAttributes) {
            toast.error("Please fix validation errors before submitting");
            return;
        }
        setIsProcessing(true);
        try {
            const validAttrs = attributes.filter(a => a.key && a.value);
            const keys = validAttrs.map(a => a.key.trim());
            const values = validAttrs.map(a => a.value.trim());
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
                const parsed: { id: string; keys: string[]; values: string[] }[] = [];
                const errors: string[] = [];

                results.data.forEach((row: any, rowIndex: number) => {
                    if (!row.id) return;

                    if (!isValidNftId(row.id)) {
                        errors.push(`Row ${rowIndex + 1}: Invalid NFT ID "${row.id}"`);
                        return;
                    }

                    const id = row.id;
                    const keys: string[] = [];
                    const values: string[] = [];

                    Object.keys(row).forEach(header => {
                        if (header !== 'id' && row[header]) {
                            if (!isValidTraitKey(header)) {
                                errors.push(`Row ${rowIndex + 1}: Invalid trait key "${header}"`);
                            } else if (!isValidTraitValue(row[header])) {
                                errors.push(`Row ${rowIndex + 1}: Invalid trait value for "${header}"`);
                            } else {
                                keys.push(header);
                                values.push(row[header]);
                            }
                        }
                    });
                    if (keys.length > 0) {
                        parsed.push({ id, keys, values });
                    }
                });

                if (errors.length > 0) {
                    toast.error(`${errors.length} validation errors found`, {
                        description: errors.slice(0, 3).join("; ") + (errors.length > 3 ? "..." : ""),
                    });
                }

                setBulkAttributes(parsed);
                if (parsed.length > 0) {
                    toast.success(`Parsed attributes for ${parsed.length} NFTs`);
                }
            }
        });
    };

    const handleSubmitBulkAttributes = async () => {
        if (bulkAttributes.length === 0) return;
        setIsProcessing(true);
        try {
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
        if (!canSubmitUrl) {
            toast.error("Please fix validation errors before submitting");
            return;
        }
        setIsProcessing(true);
        try {
            await addUrl(Number(urlNftId), url.trim());
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
                const parsed: { id: string; url: string }[] = [];
                const errors: string[] = [];

                results.data.forEach((row: any, rowIndex: number) => {
                    if (row[0] && row[1]) {
                        if (!isValidNftId(row[0])) {
                            errors.push(`Row ${rowIndex + 1}: Invalid NFT ID "${row[0]}"`);
                        } else if (!isValidUrl(row[1])) {
                            errors.push(`Row ${rowIndex + 1}: Invalid URL "${row[1]}"`);
                        } else {
                            parsed.push({ id: row[0], url: row[1] });
                        }
                    }
                });

                if (errors.length > 0) {
                    toast.error(`${errors.length} validation errors found`, {
                        description: errors.slice(0, 3).join("; ") + (errors.length > 3 ? "..." : ""),
                    });
                }

                setBulkUrls(parsed);
                if (parsed.length > 0) {
                    toast.success(`Parsed URLs for ${parsed.length} NFTs`);
                }
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

    const getFieldError = (field: string, errors: ValidationError[]): string | undefined => {
        return errors.find(e => e.field === field)?.message;
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
                            <div className="space-y-2">
                                <div className="flex gap-4">
                                    <Input
                                        placeholder="NFT ID"
                                        value={nftId}
                                        onChange={e => setNftId(e.target.value)}
                                        className={`w-32 ${getFieldError("nftId", attributeValidation) ? "border-red-500" : ""}`}
                                        type="number"
                                        min="0"
                                    />
                                </div>
                                {getFieldError("nftId", attributeValidation) && (
                                    <p className="text-xs text-red-500 flex items-center gap-1">
                                        <AlertCircle className="w-3 h-3" />
                                        {getFieldError("nftId", attributeValidation)}
                                    </p>
                                )}
                            </div>
                            {attributes.map((attr, i) => (
                                <div key={i} className="space-y-1">
                                    <div className="flex gap-4">
                                        <Input
                                            placeholder="Trait Type"
                                            value={attr.key}
                                            onChange={e => handleAttributeChange(i, "key", e.target.value)}
                                            className={getFieldError(`trait-key-${i}`, attributeValidation) ? "border-red-500" : ""}
                                        />
                                        <Input
                                            placeholder="Value"
                                            value={attr.value}
                                            onChange={e => handleAttributeChange(i, "value", e.target.value)}
                                            className={getFieldError(`trait-value-${i}`, attributeValidation) ? "border-red-500" : ""}
                                        />
                                        <Button variant="ghost" size="icon" onClick={() => handleRemoveAttributeField(i)}>
                                            <Trash2 className="w-4 h-4 text-red-500" />
                                        </Button>
                                    </div>
                                    {(getFieldError(`trait-key-${i}`, attributeValidation) || getFieldError(`trait-value-${i}`, attributeValidation)) && (
                                        <p className="text-xs text-red-500 flex items-center gap-1">
                                            <AlertCircle className="w-3 h-3" />
                                            {getFieldError(`trait-key-${i}`, attributeValidation) || getFieldError(`trait-value-${i}`, attributeValidation)}
                                        </p>
                                    )}
                                </div>
                            ))}
                            <Button variant="outline" size="sm" onClick={handleAddAttributeField}>
                                <Plus className="w-4 h-4 mr-2" /> Add Trait
                            </Button>
                            <Button
                                onClick={handleSubmitSingleAttributes}
                                disabled={isProcessing || !canSubmitAttributes}
                                className="w-full"
                            >
                                {isProcessing ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                Save Attributes
                            </Button>
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
                                    {isProcessing ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
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
                            <div className="space-y-2">
                                <div className="flex gap-4">
                                    <Input
                                        placeholder="NFT ID"
                                        value={urlNftId}
                                        onChange={e => setUrlNftId(e.target.value)}
                                        className={`w-32 ${getFieldError("urlNftId", urlValidation) ? "border-red-500" : ""}`}
                                        type="number"
                                        min="0"
                                    />
                                    <Input
                                        placeholder="Image/Metadata URL (https://, ipfs://, ar://)"
                                        value={url}
                                        onChange={e => setUrl(e.target.value)}
                                        className={`flex-1 ${getFieldError("url", urlValidation) ? "border-red-500" : ""}`}
                                    />
                                </div>
                                {(getFieldError("urlNftId", urlValidation) || getFieldError("url", urlValidation)) && (
                                    <p className="text-xs text-red-500 flex items-center gap-1">
                                        <AlertCircle className="w-3 h-3" />
                                        {getFieldError("urlNftId", urlValidation) || getFieldError("url", urlValidation)}
                                    </p>
                                )}
                            </div>
                            <Button
                                onClick={handleSubmitSingleUrl}
                                disabled={isProcessing || !canSubmitUrl}
                                className="w-full"
                            >
                                {isProcessing ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
                                Save URL
                            </Button>
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
                                    {isProcessing ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
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
