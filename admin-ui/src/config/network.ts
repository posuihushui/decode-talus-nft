import { getFullnodeUrl } from "@mysten/sui/client";

export const NETWORK_CONFIG = {
  testnet: {
    network: "testnet" as const,
    rpcUrl: getFullnodeUrl("testnet"),
    packageId: "0x01da5a22ea61747c242789f29b9e825380fc043808a56a3d61b36913086be43f",
    registryId: "0x89e0c22e871788d06340b9c211fa204e74d018fe6d3afba96196035cd16d6c0d",
    attributesId: "0x4234020c21ed0216b0f6ed6949e939468f581d18f7dde714bac4a4daa114bd86",
    transferPolicyId: "0xb667f58be77e20f6910a95ebc56bf47f93e638722c63f1674ea7787960907168",
    transferPolicyCapId: "0x5265c90204ec6422a673879fc8ba5d56038ef847e4d12d5f3b2c130e7816a697",
    adminCapId: "0xa715bb53c23652929e81c516940e05d6cf0821d989ef6561a279078db5a27793",
  },
  mainnet: {
    network: "mainnet" as const,
    rpcUrl: getFullnodeUrl("mainnet"),
    packageId: "0x75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423",
    registryId: "0x9e9ca64999421d654a72ef7d257102e042cd6f8ea8202f36087ace43750c5d8f",
    attributesId: "0x5ac88348dea35c6a3ac3db48b101564484186700f811a7048d86abadd7075cbc",
    transferPolicyId: "0x143e29ba830c1ebdc79424a5c6f33d77f9f51751fbb0834fba61a66f395c2f0d",
    transferPolicyCapId: "0xb2e93d192d7ea6842afcdaf86b0deccaf5423c21b88549b2d47f138921edf933",
    adminCapId: "0xfbf56dd3e1451b69d1d6fd4234391bf8ac98f82ee0724a0a64228ad096e8af69",
  },
};

// Default network based on environment variable
export const defaultNetwork = (process.env.NEXT_PUBLIC_DEFAULT_NETWORK as "testnet" | "mainnet") || "testnet";

// Export NETWORK for simpler usage
export const NETWORK = NETWORK_CONFIG[defaultNetwork];

export type NetworkConfig = typeof NETWORK_CONFIG.testnet;
