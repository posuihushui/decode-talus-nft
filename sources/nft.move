/// Tally NFT Module
/// A Move smart contract for minting and managing Tally NFTs on Sui blockchain.
/// Features include: public minting, early access tickets, free tickets, reveal mechanism,
/// royalty rules, and kiosk-locked trading.
module tally_nft::nft {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::table::{Self, Table};
    use sui::package::{Self, Publisher};
    use sui::display::{Self, Display};
    use sui::url::{Self, Url};
    use sui::vec_map::{Self, VecMap};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use std::string::{Self, String};
    use std::option;
    use kiosk::kiosk_lock_rule;
    use kiosk::royalty_rule;

    // ============== Constants ==============

    const COLLECTION_SIZE: u64 = 5555;
    const MAX_NFTS_PER_ADDRESS: u64 = 2;
    const PUBLIC_MINT_PRICE: u64 = 33_000_000_000; // 33 SUI
    const DISCOUNTED_MINT_PRICE: u64 = 5_000_000_000; // 5 SUI
    const MINTS_PER_TICKET: u64 = 1;
    const ROYALTY_BPS: u16 = 100; // 1%

    // ============== Error Codes ==============

    /// Sender does not have enough balance to mint.
    const EInsufficientBalance: u64 = 9223373750546726913;

    /// NFT mint amount is not between 0 and MINTS_PER_TICKET, or address has reached mint limit.
    const EAmountLimit: u64 = 9223373887986073607;

    /// Sender does not have enough balance to mint (for early mint).
    const EInsufficientBalanceEarly: u64 = 9223373913755484161;

    /// NFT mint amount is not between 0 and MINTS_PER_TICKET (for free mint).
    const EAmountLimitFree: u64 = 9223374098439471111;

    /// Attributes or URLs have already been added to the shared Attributes object.
    const EAlreadyPublished: u64 = 9223374278828359691;

    /// URL already exists for this NFT number.
    const EUrlAlreadyPublished: u64 = 9223374416267313163;

    /// Minting or Revealing has not started.
    const ENotStarted: u64 = 9223374669669859331;

    /// NFT has already been revealed.
    const EAlreadyRevealed: u64 = 9223374691145089033;

    /// All NFTs are minted out (admin mint).
    const EMintedOutAdmin: u64 = 9223375150706327557;

    /// Minting has not started (public mint).
    const ENotStartedPublic: u64 = 9223375283850182659;

    /// All NFTs are minted out.
    const EMintedOut: u64 = 9223375301030182917;

    /// NFT mint amount is not valid.
    const EInvalidAmount: u64 = 9223375313915215879;

    /// Address has reached max mint limit.
    const EMaxMintReached: u64 = 9223375404109529095;

    // ============== Structs ==============

    /// One-time witness for the module
    public struct NFT has drop {}

    /// The Tally NFT struct
    public struct Tally has store, key {
        id: UID,
        number: u64,
        description: String,
        url: Url,
        attributes: VecMap<String, String>
    }

    /// Early access mint ticket
    public struct TallyEarlyTicket has key {
        id: UID
    }

    /// Free mint ticket
    public struct TallyFreeTicket has key {
        id: UID
    }

    /// Registry that tracks minting state and collects payments
    public struct TallyRegistry has key {
        id: UID,
        balance: Balance<SUI>,
        minted: u64,
        collection_size: u64,
        can_public_mint: bool,
        max_nfts_per_address: u64,
        addresses_minted: Table<address, u64>,
        public_mint_price: u64,
        discounted_mint_price: u64,
        early_mints: u64,
        early_mints_used: u64,
        free_mints: u64,
        free_mints_used: u64
    }

    /// Stores NFT attributes and URLs for reveal
    public struct TallyAttributes has key {
        id: UID,
        nft_attributes: Table<u64, VecMap<String, String>>,
        nft_urls: Table<u64, Url>,
        revealed_nfts: Table<u64, bool>,
        can_reveal: bool
    }

    /// Admin capability for privileged operations
    public struct AdminCap has store, key {
        id: UID
    }

    /// Rule to disable trading until enabled
    public struct TradeDisabledRule has drop {}

    /// Enum for early access status
    public enum EarlyAccess has drop {
        Yes {},
        No {}
    }

    // ============== Init Function ==============

    fun init(otw: NFT, ctx: &mut TxContext) {
        // Claim publisher
        let publisher = package::claim(otw, ctx);

        // Setup Display for Tally NFT
        let tally_display_keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"attributes"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let tally_display_values = vector[
            string::utf8(b"Tally #{number}"),
            string::utf8(b"{description}"),
            string::utf8(b"{url}"),
            string::utf8(b"{attributes}"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut tally_display = display::new_with_fields<Tally>(
            &publisher,
            tally_display_keys,
            tally_display_values,
            ctx
        );
        display::update_version(&mut tally_display);
        transfer::public_transfer(tally_display, tx_context::sender(ctx));

        // Setup Display for TallyEarlyTicket
        let early_ticket_keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let early_ticket_values = vector[
            string::utf8(b"Tally Mint Early Ticket"),
            string::utf8(b"This ticket gives you early access to Tally NFTs"),
            string::utf8(b"https://tallys.talus.network/unminted.png"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut early_display = display::new_with_fields<TallyEarlyTicket>(
            &publisher,
            early_ticket_keys,
            early_ticket_values,
            ctx
        );
        display::update_version(&mut early_display);
        transfer::public_transfer(early_display, tx_context::sender(ctx));

        // Setup Display for TallyFreeTicket
        let free_ticket_keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let free_ticket_values = vector[
            string::utf8(b"Tally Mint Free Ticket"),
            string::utf8(b"This ticket gives you free early access to Tally NFTs."),
            string::utf8(b"https://tallys.talus.network/unminted.png"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut free_display = display::new_with_fields<TallyFreeTicket>(
            &publisher,
            free_ticket_keys,
            free_ticket_values,
            ctx
        );
        display::update_version(&mut free_display);
        transfer::public_transfer(free_display, tx_context::sender(ctx));

        // Create TallyRegistry
        let registry = TallyRegistry {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            minted: 0,
            collection_size: COLLECTION_SIZE,
            can_public_mint: false,
            max_nfts_per_address: MAX_NFTS_PER_ADDRESS,
            addresses_minted: table::new<address, u64>(ctx),
            public_mint_price: PUBLIC_MINT_PRICE,
            discounted_mint_price: DISCOUNTED_MINT_PRICE,
            early_mints: 0,
            early_mints_used: 0,
            free_mints: 0,
            free_mints_used: 0
        };

        // Setup Display for TallyRegistry
        let registry_keys = vector[
            string::utf8(b"name"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let registry_values = vector[
            string::utf8(b"Tally NFT Registry"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut registry_display = display::new_with_fields<TallyRegistry>(
            &publisher,
            registry_keys,
            registry_values,
            ctx
        );
        display::update_version(&mut registry_display);
        transfer::public_transfer(registry_display, tx_context::sender(ctx));

        // Create TallyAttributes
        let attributes = TallyAttributes {
            id: object::new(ctx),
            nft_attributes: table::new<u64, VecMap<String, String>>(ctx),
            nft_urls: table::new<u64, Url>(ctx),
            revealed_nfts: table::new<u64, bool>(ctx),
            can_reveal: false
        };

        // Setup Display for TallyAttributes
        let attributes_keys = vector[
            string::utf8(b"name"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let attributes_values = vector[
            string::utf8(b"Tally Attributes Registry"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut attributes_display = display::new_with_fields<TallyAttributes>(
            &publisher,
            attributes_keys,
            attributes_values,
            ctx
        );
        display::update_version(&mut attributes_display);
        transfer::public_transfer(attributes_display, tx_context::sender(ctx));

        // Create AdminCap and transfer to deployer
        let admin_cap = AdminCap {
            id: object::new(ctx)
        };
        transfer::transfer(admin_cap, tx_context::sender(ctx));

        // Create TransferPolicy with kiosk lock rule and royalty rule
        let (mut transfer_policy, transfer_policy_cap) = transfer_policy::new<Tally>(&publisher, ctx);

        // Add kiosk lock rule
        kiosk_lock_rule::add<Tally>(&mut transfer_policy, &transfer_policy_cap);

        // Add royalty rule (1% royalty, 0 minimum)
        royalty_rule::add<Tally>(&mut transfer_policy, &transfer_policy_cap, ROYALTY_BPS, 0);

        // Add trade disabled rule
        transfer_policy::add_rule<Tally, TradeDisabledRule, vector<u8>>(
            TradeDisabledRule {},
            &mut transfer_policy,
            &transfer_policy_cap,
            b"no_config"
        );

        // Share transfer policy and transfer cap to deployer
        transfer::public_share_object(transfer_policy);
        transfer::public_transfer(transfer_policy_cap, tx_context::sender(ctx));

        // Transfer publisher to deployer
        transfer::public_transfer(publisher, tx_context::sender(ctx));

        // Share registry and attributes
        transfer::share_object(registry);
        transfer::share_object(attributes);
    }

    // ============== Admin Functions ==============

    /// Start public minting
    public entry fun start_minting(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        _ctx: &mut TxContext
    ) {
        registry.can_public_mint = true;
    }

    /// Stop public minting
    public entry fun stop_minting(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        _ctx: &mut TxContext
    ) {
        registry.can_public_mint = false;
    }

    /// Enable trading by removing the TradeDisabledRule
    public entry fun start_trading(
        _admin: &AdminCap,
        policy: &mut TransferPolicy<Tally>,
        cap: &TransferPolicyCap<Tally>,
        _ctx: &mut TxContext
    ) {
        transfer_policy::remove_rule<Tally, TradeDisabledRule, vector<u8>>(policy, cap);
    }

    /// Distribute free tickets to a list of addresses
    public entry fun distribute_free_tickets(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        addresses: vector<address>,
        ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = addresses.length();
        while (i < len) {
            let ticket = TallyFreeTicket {
                id: object::new(ctx)
            };
            transfer::transfer(ticket, addresses[i]);
            i = i + 1;
        };
        registry.free_mints = registry.free_mints + (len * MINTS_PER_TICKET);
    }

    /// Distribute early access tickets to a list of addresses
    public entry fun distribute_early_tickets(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        addresses: vector<address>,
        ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = addresses.length();
        while (i < len) {
            let ticket = TallyEarlyTicket {
                id: object::new(ctx)
            };
            transfer::transfer(ticket, addresses[i]);
            i = i + 1;
        };
        registry.early_mints = registry.early_mints + (len * MINTS_PER_TICKET);
    }

    /// Admin mint function (no payment required)
    public entry fun mint_tally_admin(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        amount: u64,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        admin_mint(registry, amount, policy, kiosk, kiosk_cap, ctx);
    }

    /// Add attributes for a specific NFT number
    public entry fun add_attributes(
        _admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_number: u64,
        keys: vector<String>,
        values: vector<String>,
        _ctx: &mut TxContext
    ) {
        assert!(!table::contains(&attributes.nft_attributes, nft_number), EAlreadyPublished);
        let attr_map = vec_map::from_keys_values(keys, values);
        table::add(&mut attributes.nft_attributes, nft_number, attr_map);
    }

    /// Bulk add attributes for multiple NFTs
    public entry fun bulk_add_attributes(
        admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_numbers: vector<u64>,
        keys_list: vector<vector<String>>,
        values_list: vector<vector<String>>,
        ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = nft_numbers.length();
        while (i < len) {
            add_attributes(admin, attributes, nft_numbers[i], keys_list[i], values_list[i], ctx);
            i = i + 1;
        };
    }

    /// Add URL for a specific NFT number
    public entry fun add_url(
        _admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_number: u64,
        url_string: String,
        _ctx: &mut TxContext
    ) {
        assert!(!table::contains(&attributes.nft_urls, nft_number), EUrlAlreadyPublished);
        let nft_url = url::new_unsafe_from_bytes(string::into_bytes(url_string));
        table::add(&mut attributes.nft_urls, nft_number, nft_url);
    }

    /// Bulk add URLs for multiple NFTs
    public entry fun bulk_add_urls(
        admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_numbers: vector<u64>,
        urls: vector<String>,
        ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = nft_numbers.length();
        while (i < len) {
            add_url(admin, attributes, nft_numbers[i], urls[i], ctx);
            i = i + 1;
        };
    }

    /// Remove attributes for specific NFT numbers
    public entry fun remove_attributes(
        _admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_numbers: vector<u64>,
        _ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = nft_numbers.length();
        while (i < len) {
            table::remove(&mut attributes.nft_attributes, nft_numbers[i]);
            i = i + 1;
        };
    }

    /// Remove URLs for specific NFT numbers
    public entry fun remove_urls(
        _admin: &AdminCap,
        attributes: &mut TallyAttributes,
        nft_numbers: vector<u64>,
        _ctx: &mut TxContext
    ) {
        let mut i = 0;
        let len = nft_numbers.length();
        while (i < len) {
            table::remove(&mut attributes.nft_urls, nft_numbers[i]);
            i = i + 1;
        };
    }

    /// Enable NFT revealing
    public entry fun start_revealing(
        _admin: &AdminCap,
        attributes: &mut TallyAttributes,
        _ctx: &mut TxContext
    ) {
        attributes.can_reveal = true;
    }

    /// Withdraw collected balance to admin
    public entry fun withdraw_balance(
        _admin: &AdminCap,
        registry: &mut TallyRegistry,
        ctx: &mut TxContext
    ) {
        let withdrawn = balance::withdraw_all(&mut registry.balance);
        let coin = coin::from_balance(withdrawn, ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    /// Withdraw collected royalties
    public entry fun withdraw_royalties(
        _admin: &AdminCap,
        policy: &mut TransferPolicy<Tally>,
        cap: &TransferPolicyCap<Tally>,
        ctx: &mut TxContext
    ) {
        let coin = transfer_policy::withdraw(policy, cap, option::none<u64>(), ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    // ============== Public Mint Functions ==============

    /// Public mint with SUI payment
    public entry fun mint_tally(
        registry: &mut TallyRegistry,
        amount: u64,
        mut payment: Coin<SUI>,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        let total_cost = amount * registry.public_mint_price;
        assert!(coin::value(&payment) >= total_cost, EInsufficientBalance);

        // Split exact payment amount
        let paid = coin::split(&mut payment, total_cost, ctx);
        balance::join(&mut registry.balance, coin::into_balance(paid));

        // Return change if any
        if (coin::value(&payment) > 0) {
            transfer::public_transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };

        // Mint NFTs
        mint(registry, amount, EarlyAccess::No {}, policy, kiosk, kiosk_cap, ctx);
    }

    /// Early access mint with discounted price (requires TallyEarlyTicket)
    public entry fun mint_tally_early(
        registry: &mut TallyRegistry,
        amount: u64,
        mut payment: Coin<SUI>,
        ticket: TallyEarlyTicket,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        assert!(amount <= MINTS_PER_TICKET, EAmountLimit);

        let total_cost = amount * registry.discounted_mint_price;
        assert!(coin::value(&payment) >= total_cost, EInsufficientBalanceEarly);

        // Split exact payment amount
        let paid = coin::split(&mut payment, total_cost, ctx);
        balance::join(&mut registry.balance, coin::into_balance(paid));

        // Return change if any
        if (coin::value(&payment) > 0) {
            transfer::public_transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };

        // Mint NFTs with early access
        mint(registry, amount, EarlyAccess::Yes {}, policy, kiosk, kiosk_cap, ctx);

        // Update early mints used
        registry.early_mints_used = registry.early_mints_used + amount;

        // Burn or return ticket based on remaining mints
        let should_burn = !has_mint_left(registry, tx_context::sender(ctx)) || amount >= MINTS_PER_TICKET;
        if (should_burn) {
            let TallyEarlyTicket { id } = ticket;
            object::delete(id);
        } else {
            transfer::transfer(ticket, tx_context::sender(ctx));
        };
    }

    /// Free mint (requires TallyFreeTicket)
    public entry fun mint_tally_free(
        registry: &mut TallyRegistry,
        amount: u64,
        ticket: TallyFreeTicket,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        assert!(amount <= MINTS_PER_TICKET, EAmountLimitFree);

        // Mint NFTs with early access (free tickets get early access pricing/priority)
        mint(registry, amount, EarlyAccess::Yes {}, policy, kiosk, kiosk_cap, ctx);

        // Update free mints used
        registry.free_mints_used = registry.free_mints_used + amount;

        // Burn or return ticket based on remaining mints
        let should_burn = !has_mint_left(registry, tx_context::sender(ctx)) || amount >= MINTS_PER_TICKET;
        if (should_burn) {
            let TallyFreeTicket { id } = ticket;
            object::delete(id);
        } else {
            transfer::transfer(ticket, tx_context::sender(ctx));
        };
    }

    // ============== Reveal Function ==============

    /// Reveal an NFT's attributes and URL
    public entry fun reveal_nft(
        attributes: &mut TallyAttributes,
        nft_id: ID,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        _ctx: &mut TxContext
    ) {
        assert!(attributes.can_reveal, ENotStarted);

        let nft = kiosk::borrow_mut<Tally>(kiosk, kiosk_cap, nft_id);

        assert!(!table::contains(&attributes.revealed_nfts, nft.number), EAlreadyRevealed);

        // Copy attributes to NFT
        let attr_map = table::borrow(&attributes.nft_attributes, nft.number);
        let mut i = 0;
        let size = vec_map::size(attr_map);
        while (i < size) {
            let (key, value) = vec_map::get_entry_by_idx(attr_map, i);
            vec_map::insert(&mut nft.attributes, *key, *value);
            i = i + 1;
        };

        // Update URL
        let new_url = table::borrow(&attributes.nft_urls, nft.number);
        nft.url = *new_url;

        // Mark as revealed
        table::add(&mut attributes.revealed_nfts, nft.number, true);
    }

    // ============== Burn Functions ==============

    /// Burn a free ticket
    public entry fun burn_free_ticket(ticket: TallyFreeTicket, _ctx: &mut TxContext) {
        let TallyFreeTicket { id } = ticket;
        object::delete(id);
    }

    /// Burn an early ticket
    public entry fun burn_early_ticket(ticket: TallyEarlyTicket, _ctx: &mut TxContext) {
        let TallyEarlyTicket { id } = ticket;
        object::delete(id);
    }

    // ============== Internal Functions ==============

    /// Internal mint function
    fun mint(
        registry: &mut TallyRegistry,
        amount: u64,
        early_access: EarlyAccess,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        check_can_public_mint(registry, amount, tx_context::sender(ctx), &early_access);

        let mut i = 0;
        while (i < amount) {
            let nft = Tally {
                id: object::new(ctx),
                number: registry.minted,
                description: string::utf8(b"Forged in the heart of the Talus Kingdom, Tally NFTs grant their bearers the mantle of guardians, shaping the fate of AI agents on Sui and guiding its next great evolution"),
                url: url::new_unsafe_from_bytes(b"https://tallys.talus.network/unminted.png"),
                attributes: vec_map::empty<String, String>()
            };

            registry.minted = registry.minted + 1;
            kiosk::lock(kiosk, kiosk_cap, policy, nft);
            i = i + 1;
        };

        add_addresses_minted(registry, tx_context::sender(ctx), amount);
    }

    /// Admin mint (bypasses public mint checks)
    fun admin_mint(
        registry: &mut TallyRegistry,
        amount: u64,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        kiosk_cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        assert!(registry.minted + amount <= registry.collection_size, EMintedOutAdmin);

        let mut i = 0;
        while (i < amount) {
            let nft = Tally {
                id: object::new(ctx),
                number: registry.minted,
                description: string::utf8(b"Forged in the heart of the Talus Kingdom, Tally NFTs grant their bearers the mantle of guardians, shaping the fate of AI agents on Sui and guiding its next great evolution"),
                url: url::new_unsafe_from_bytes(b"https://tallys.talus.network/unminted.png"),
                attributes: vec_map::empty<String, String>()
            };

            registry.minted = registry.minted + 1;
            kiosk::lock(kiosk, kiosk_cap, policy, nft);
            i = i + 1;
        };

        add_addresses_minted(registry, tx_context::sender(ctx), amount);
    }

    /// Check if public minting is allowed
    fun check_can_public_mint(
        registry: &TallyRegistry,
        amount: u64,
        sender: address,
        early_access: &EarlyAccess
    ) {
        // If not early access, check if public mint is enabled
        match (early_access) {
            EarlyAccess::Yes {} => {},
            EarlyAccess::No {} => {
                assert!(registry.can_public_mint, ENotStartedPublic);
            }
        };

        // Check collection size
        assert!(registry.minted + amount <= registry.collection_size, EMintedOut);

        // Check amount is valid (0 < amount <= 2)
        assert!(amount > 0 && amount <= MAX_NFTS_PER_ADDRESS, EInvalidAmount);

        // Check max NFTs per address
        check_max_nfts_per_address(registry, sender, amount);
    }

    /// Add to addresses minted table
    fun add_addresses_minted(registry: &mut TallyRegistry, addr: address, amount: u64) {
        if (table::contains(&registry.addresses_minted, addr)) {
            let current = table::borrow_mut(&mut registry.addresses_minted, addr);
            *current = *current + amount;
        } else {
            table::add(&mut registry.addresses_minted, addr, amount);
        };
    }

    /// Check if address has not exceeded max NFTs
    fun check_max_nfts_per_address(registry: &TallyRegistry, addr: address, amount: u64) {
        if (table::contains(&registry.addresses_minted, addr)) {
            let current = table::borrow(&registry.addresses_minted, addr);
            assert!(*current + amount <= registry.max_nfts_per_address, EMaxMintReached);
        };
    }

    /// Check if address has mints left
    fun has_mint_left(registry: &TallyRegistry, addr: address): bool {
        if (table::contains(&registry.addresses_minted, addr)) {
            let current = table::borrow(&registry.addresses_minted, addr);
            *current < registry.max_nfts_per_address
        } else {
            true
        }
    }

    // ============== View Functions ==============

    public fun number(nft: &Tally): &u64 {
        &nft.number
    }

    public fun description(nft: &Tally): &String {
        &nft.description
    }

    public fun url(nft: &Tally): &Url {
        &nft.url
    }

    public fun attributes(nft: &Tally): &VecMap<String, String> {
        &nft.attributes
    }

    public fun balance(registry: &TallyRegistry): &Balance<SUI> {
        &registry.balance
    }

    public fun minted(registry: &TallyRegistry): &u64 {
        &registry.minted
    }

    public fun collection_size(registry: &TallyRegistry): &u64 {
        &registry.collection_size
    }

    public fun can_public_mint(registry: &TallyRegistry): &bool {
        &registry.can_public_mint
    }

    public fun max_nfts_per_address(registry: &TallyRegistry): &u64 {
        &registry.max_nfts_per_address
    }

    public fun addresses_minted(registry: &TallyRegistry): &Table<address, u64> {
        &registry.addresses_minted
    }

    public fun public_mint_price(registry: &TallyRegistry): &u64 {
        &registry.public_mint_price
    }

    public fun early_mints(registry: &TallyRegistry): &u64 {
        &registry.early_mints
    }

    public fun early_mints_used(registry: &TallyRegistry): &u64 {
        &registry.early_mints_used
    }

    public fun free_mints(registry: &TallyRegistry): &u64 {
        &registry.free_mints
    }

    public fun free_mints_used(registry: &TallyRegistry): &u64 {
        &registry.free_mints_used
    }
}
