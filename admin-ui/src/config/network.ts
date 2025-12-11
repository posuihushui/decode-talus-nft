import { getFullnodeUrl } from "@mysten/sui/client";

export const NETWORK_CONFIG = {
  testnet: {
    network: "testnet",
    rpcUrl: getFullnodeUrl("testnet"),
    packageId: "0x01da5a22ea61747c242789f29b9e825380fc043808a56a3d61b36913086be43f",
    registryId: "0x89e0c22e871788d06340b9c211fa204e74d018fe6d3afba96196035cd16d6c0d",
    attributesId: "0x4234020c21ed0216b0f6ed6949e939468f581d18f7dde714bac4a4daa114bd86",
    transferPolicyId: "0xb667f58be77e20f6910a95ebc56bf47f93e638722c63f1674ea7787960907168",
    transferPolicyCapId: "0x5265c90204ec6422a673879fc8ba5d56038ef847e4d12d5f3b2c130e7816a697",
    adminCapId: "0xa715bb53c23652929e81c516940e05d6cf0821d989ef6561a279078db5a27793",
  },
  mainnet: {
    network: "mainnet",
    rpcUrl: getFullnodeUrl("mainnet"),
    packageId: "",
    registryId: "",
    attributesId: "",
    transferPolicyId: "",
    transferPolicyCapId: "",
    adminCapId: "",
  },
};

export type NetworkConfig = typeof NETWORK_CONFIG.testnet;
