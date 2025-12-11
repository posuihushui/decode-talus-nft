# Tally NFT Project - Product Requirements Document (PRD)

Based on the analysis of `sources/nft.move`.

## 1. Project Overview
A detailed NFT project on the Sui blockchain managed by the `tally_nft::nft` module. It features a tiered minting system (Public, Early Access, Free), a reveal mechanism for metadata, and strict trading controls using Sui Kiosk.

## 2. Functional Requirements

### 2.1 Minting System
The contract supports three distinct minting phases/methods:
*   **Public Mint**:
    *   **Price**: 33 SUI.
    *   **Condition**: `can_public_mint` must be set to `true` by admin.
    *   **Limit**: Subject to `MAX_NFTS_PER_ADDRESS` (2) and global `COLLECTION_SIZE` (5555).
*   **Early Access Mint**:
    *   **Requirement**: User must hold a `TallyEarlyTicket`.
    *   **Price**: 5 SUI (Discounted).
    *   **Consumption**: Ticket is burned after use (1 mint per ticket).
*   **Free Mint**:
    *   **Requirement**: User must hold a `TallyFreeTicket`.
    *   **Price**: 0 SUI.
    *   **Consumption**: Ticket is burned after use (1 mint per ticket).
*   **Admin Mint**:
    *   Allows administrator to mint NFTs directly without payment.
    *   Bypasses public mint status checks but respects collection size.

### 2.2 NFT Properties & Metadata
*   **Initial State**: Minted with placeholder metadata (Image: `unminted.png`, Description: "Forged in the heart...").
*   **Reveal Process**:
    1.  Admin uploads real attributes and URLs to `TallyAttributes` shared object using `add_attributes` and `add_url` (or bulk variants).
    2.  Admin enables revealing via `start_revealing`.
    3.  Users call `reveal_nft` to update their specific NFT's metadata from the registry.
    4.  **Constraint**: Reveal creates a permanent update to the NFT's fields (`url`, `attributes`).

### 2.3 Trading & Marketplace Integration
*   **Sui Kiosk Enforcement**: All minted NFTs are automatically locked into a Sui Kiosk (`kiosk::lock`).
*   **Trading Restrictions**:
    *   Initially, trading is **disabled** via a `TradeDisabledRule` ("no_config").
    *   Admin must call `start_trading` to remove this rule and allow transfers.
*   **Royalties**:
    *   Enforces a **1% royalty** (`100 BPS`) on secondary sales via `royalty_rule`.

### 2.4 Admin Capabilities
The `AdminCap` holder has extensive control:
*   **Minting Control**: Start/Stop public minting (`start_minting`, `stop_minting`).
*   **Distribution**: Airdrop tickets (`distribute_early_tickets`, `distribute_free_tickets`).
*   **Metadata Management**: Add/Remove pending descriptions and URLs for the reveal phase.
*   **Trading Control**: Enable trading (`start_trading`).
*   **Financials**:
    *   `withdraw_balance`: Withdraw SUI collected from mint sales.
    *   `withdraw_royalties`: Withdraw royalties accumulated in the Transfer Policy.

## 3. Technical Constraints & Constants
*   **Collection Size**: Max 5,555 NFTs.
*   **Wallet Limit**: Max 2 NFTs per address (public mint check).
*   **Ticket Logic**: `MINTS_PER_TICKET` is set to 1. Using a ticket consumes it.
*   **Mint Prices**: Hardcoded constants (33 SUI Public, 5 SUI Early).

## 4. Important Notes & Attention Points
1.  **Ticket Consumption**: Tickets are NFTs. When used for minting, they are deleted (`object::delete`). Ensure users are aware that tickets are one-time use.
2.  **Kiosk Mandatory**: The contract forces the use of Kiosks. Users cannot hold the NFT in their wallet directly without a Kiosk. Frontend must handle Kiosk transaction building.
3.  **Trading Lock**: Users cannot trade or transfer their NFTs immediately after minting until the Admin explicitly enables trading.
4.  **Metadata Trust**: The "Reveal" is on-chain but data is supplied by the Admin into a shared object. The mapping of NFT ID to Attributes is controlled by the Admin.
5.  **Address Limits**: The 2 NFT limit per address applies to Public Mint checks. Clarify if this limit should also restrict Early/Free mints (current code checks `check_max_nfts_per_address` in `check_can_public_mint`, which is called by `mint` internal function utilized by ALL mint functions). **Note**: The code calls `check_can_public_mint` even for ticket mints, so the 2 NFT limit applies globally per address.
6.  **Concurrency**: High demand mints might contend on the `TallyRegistry` shared object.
