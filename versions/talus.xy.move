module 0x75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423::nft {
    use std::option;
    use std::string::{Self, String};
    use std::vector;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::display;
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::object::{Self, UID, ID};
    use sui::package::{Self, Publisher};
    use sui::sui::SUI;
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::vec_map::{Self, VecMap};
    
    // External rules (based on imports)
    use 0x434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879::kiosk_lock_rule;
    use 0x434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879::royalty_rule;

    //Errors
    const EInsufficientBalance: u64 = 0;
    const ENotStarted: u64 = 2;
    const EMintedOut: u64 = 4;
    const EAmountLimit: u64 = 6;
    const EAlreadyRevealed: u64 = 8;
    const EAlreadyPublished: u64 = 10;

    // Config Constants
    const MAX_SUPPLY: u64 = 5555;
    const MAX_MINT_PER_TX: u64 = 2;
    const PUBLIC_MINT_PRICE: u64 = 33000000000; // 33 SUI
    const DISCOUNT_MINT_PRICE: u64 = 5000000000; // 5 SUI
    const MINTS_PER_TICKET: u64 = 1;
    const ROYALTY_BPS: u16 = 100; // 1%

    // --- Structs ---

    struct NFT has drop {
        dummy_field: bool
    }

    struct Tally has key, store {
        id: UID,
        number: u64,
        description: String,
        url: Url,
        attributes: VecMap<String, String>
    }

    struct TallyEarlyTicket has key {
        id: UID
    }

    struct TallyFreeTicket has key {
        id: UID
    }

    struct TallyRegistry has key {
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

    struct TallyAttributes has key {
        id: UID,
        nft_attributes: Table<u64, VecMap<String, String>>,
        nft_urls: Table<u64, Url>,
        revealed_nfts: Table<u64, bool>,
        can_reveal: bool
    }

    struct AdminCap has key, store {
        id: UID
    }

    struct TradeDisabledRule has drop {
        dummy_field: bool
    }

    public enum EarlyAccess has drop {
        Yes,
        No
    }

    // --- Init ---

    fun init(otw: NFT, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);
        let sender = tx_context::sender(ctx);

        // 1. Setup Display for Tally NFT
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"attributes"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let values = vector[
            string::utf8(b"Tally #{number}"),
            string::utf8(b"{description}"),
            string::utf8(b"{url}"),
            string::utf8(b"{attributes}"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut display_tally = display::new_with_fields<Tally>(&publisher, keys, values, ctx);
        display::update_version(&mut display_tally);
        transfer::public_transfer(display_tally, sender);

        // 2. Setup Display for Early Ticket
        let keys_early = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let values_early = vector[
            string::utf8(b"Tally Mint Early Ticket"),
            string::utf8(b"This ticket gives you early access to Tally NFTs"),
            string::utf8(b"https://tallys.talus.network/unminted.png"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut display_early = display::new_with_fields<TallyEarlyTicket>(&publisher, keys_early, values_early, ctx);
        display::update_version(&mut display_early);
        transfer::public_transfer(display_early, sender);

        // 3. Setup Display for Free Ticket
        let keys_free = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let values_free = vector[
            string::utf8(b"Tally Mint Free Ticket"),
            string::utf8(b"This ticket gives you free early access to Tally NFTs."),
            string::utf8(b"https://tallys.talus.network/unminted.png"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut display_free = display::new_with_fields<TallyFreeTicket>(&publisher, keys_free, values_free, ctx);
        display::update_version(&mut display_free);
        transfer::public_transfer(display_free, sender);

        // 4. Initialize TallyRegistry (Shared Object)
        let registry = TallyRegistry {
            id: object::new(ctx),
            balance: balance::zero(),
            minted: 0,
            collection_size: MAX_SUPPLY, // 5555
            can_public_mint: false,
            max_nfts_per_address: 2, // Default limit per address? (Logic uses map + constant)
            addresses_minted: table::new(ctx),
            public_mint_price: PUBLIC_MINT_PRICE,
            discounted_mint_price: DISCOUNT_MINT_PRICE,
            early_mints: 0,
            early_mints_used: 0,
            free_mints: 0,
            free_mints_used: 0
        };

        // Setup Display for Registry
        let keys_reg = vector[
            string::utf8(b"name"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let values_reg = vector[
            string::utf8(b"Tally NFT Registry"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut display_reg = display::new_with_fields<TallyRegistry>(&publisher, keys_reg, values_reg, ctx);
        display::update_version(&mut display_reg);
        transfer::public_transfer(display_reg, sender);
        
        // 5. Initialize TallyAttributes (Shared Object)
        let attributes = TallyAttributes {
            id: object::new(ctx),
            nft_attributes: table::new(ctx),
            nft_urls: table::new(ctx),
            revealed_nfts: table::new(ctx),
            can_reveal: false
        };

        // Setup Display for Attributes
        let keys_attr = vector[
            string::utf8(b"name"),
            string::utf8(b"project_url"),
            string::utf8(b"creator")
        ];
        let values_attr = vector[
            string::utf8(b"Tally Attributes Registry"),
            string::utf8(b"https://tallys.talus.network"),
            string::utf8(b"Talus Labs")
        ];
        let mut display_attr = display::new_with_fields<TallyAttributes>(&publisher, keys_attr, values_attr, ctx);
        display::update_version(&mut display_attr);
        transfer::public_transfer(display_attr, sender);

        // 6. Admin Cap
        let admin_cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(admin_cap, sender);

        // 7. Transfer Policy with Rules
        let (mut policy, policy_cap) = transfer_policy::new<Tally>(&publisher, ctx);
        
        // Add Kiosk Lock Rule
        kiosk_lock_rule::add(&mut policy, &policy_cap);
        
        // Add Royalty Rule
        royalty_rule::add(&mut policy, &policy_cap, ROYALTY_BPS, 0);

        // Add Trade Disabled Rule (Initially trading is paused)
        transfer_policy::add_rule(TradeDisabledRule { dummy_field: false }, &mut policy, &policy_cap, b"no_config");

        transfer::public_share_object(policy);
        transfer::public_transfer(policy_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::share_object(registry);
        transfer::share_object(attributes);
    }

    // --- Admin Functions ---

    public entry fun start_minting(_: &AdminCap, registry: &mut TallyRegistry, _ctx: &mut TxContext) {
        registry.can_public_mint = true;
    }

    public entry fun stop_minting(_: &AdminCap, registry: &mut TallyRegistry, _ctx: &mut TxContext) {
        registry.can_public_mint = false;
    }

    public entry fun start_trading(_: &AdminCap, policy: &mut TransferPolicy<Tally>, policy_cap: &TransferPolicyCap<Tally>, _ctx: &mut TxContext) {
        transfer_policy::remove_rule<Tally, TradeDisabledRule, vector<u8>>(policy, policy_cap);
    }

    public entry fun distribute_free_tickets(_: &AdminCap, registry: &mut TallyRegistry, recipients: vector<address>, ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&recipients);
        while (i < len) {
            let ticket = TallyFreeTicket { id: object::new(ctx) };
            let recipient = *vector::borrow(&recipients, i);
            transfer::transfer(ticket, recipient);
            i = i + 1;
        };
        registry.free_mints = registry.free_mints + (len * MINTS_PER_TICKET);
    }

    public entry fun distribute_early_tickets(_: &AdminCap, registry: &mut TallyRegistry, recipients: vector<address>, ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&recipients);
        while (i < len) {
            let ticket = TallyEarlyTicket { id: object::new(ctx) };
            let recipient = *vector::borrow(&recipients, i);
            transfer::transfer(ticket, recipient);
            i = i + 1;
        };
        registry.early_mints = registry.early_mints + (len * MINTS_PER_TICKET);
    }

    // --- Minting Functions ---

    public entry fun mint_tally(
        registry: &mut TallyRegistry, 
        quantity: u64, 
        mut payment: Coin<SUI>, 
        policy: &TransferPolicy<Tally>, 
        kiosk: &mut Kiosk, 
        cap: &KioskOwnerCap, 
        ctx: &mut TxContext
    ) {
        let total_price = quantity * registry.public_mint_price;
        assert!(coin::value(&payment) >= total_price, EInsufficientBalance);

        let paid = coin::split(&mut payment, total_price, ctx);
        balance::join(&mut registry.balance, coin::into_balance(paid));

        // Return change
        if (coin::value(&payment) > 0) {
            transfer::public_transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };

        mint(registry, quantity, EarlyAccess::No, policy, kiosk, cap, ctx);
    }

    public entry fun mint_tally_early(
        registry: &mut TallyRegistry,
        quantity: u64,
        mut payment: Coin<SUI>,
        ticket: TallyEarlyTicket,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        // Validation
        assert!(quantity <= MINTS_PER_TICKET, EAmountLimit);
        
        let total_price = quantity * registry.discounted_mint_price;
        assert!(coin::value(&payment) >= total_price, EInsufficientBalance);

        let paid = coin::split(&mut payment, total_price, ctx);
        balance::join(&mut registry.balance, coin::into_balance(paid));

        if (coin::value(&payment) > 0) {
            transfer::public_transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };

        mint(registry, quantity, EarlyAccess::Yes, policy, kiosk, cap, ctx);

        // Update usage stats
        registry.early_mints_used = registry.early_mints_used + quantity;

        // Logic to determine if we should burn the ticket or keep it?
        // Based on bytecode: if (has_mint_left(address) == false) or (quantity >= 1) -> burn
        // The bytecode logic here is a bit dense (Branch 92-96), but ultimately it seems to consume the ticket.
        // It deletes the ticket object.
        let TallyEarlyTicket { id } = ticket;
        object::delete(id);
    }

    public entry fun mint_tally_free(
        registry: &mut TallyRegistry,
        quantity: u64,
        ticket: TallyFreeTicket,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        assert!(quantity <= MINTS_PER_TICKET, EAmountLimit);

        mint(registry, quantity, EarlyAccess::Yes, policy, kiosk, cap, ctx);

        registry.free_mints_used = registry.free_mints_used + quantity;

        let TallyFreeTicket { id } = ticket;
        object::delete(id);
    }

    public entry fun mint_tally_admin(
        _: &AdminCap,
        registry: &mut TallyRegistry,
        quantity: u64,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        admin_mint(registry, quantity, policy, kiosk, cap, ctx);
    }

    // --- Attributes / Reveal Management ---

    public entry fun add_attributes(_: &AdminCap, attrs: &mut TallyAttributes, nft_id: u64, keys: vector<String>, values: vector<String>, _ctx: &mut TxContext) {
        assert!(!table::contains(&attrs.nft_attributes, nft_id), EAlreadyPublished);
        let attributes_map = vec_map::from_keys_values(keys, values);
        table::add(&mut attrs.nft_attributes, nft_id, attributes_map);
    }

    public entry fun bulk_add_attributes(admin: &AdminCap, attrs: &mut TallyAttributes, nft_ids: vector<u64>, all_keys: vector<vector<String>>, all_values: vector<vector<String>>, ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&nft_ids);
        while (i < len) {
            let id = *vector::borrow(&nft_ids, i);
            let keys = *vector::borrow(&all_keys, i);
            let values = *vector::borrow(&all_values, i);
            add_attributes(admin, attrs, id, keys, values, ctx);
            i = i + 1;
        }
    }

    public entry fun add_url(_: &AdminCap, attrs: &mut TallyAttributes, nft_id: u64, url_str: String, _ctx: &mut TxContext) {
        assert!(!table::contains(&attrs.nft_urls, nft_id), EAlreadyPublished);
        let url = url::new_unsafe_from_bytes(string::into_bytes(url_str));
        table::add(&mut attrs.nft_urls, nft_id, url);
    }

    public entry fun bulk_add_urls(admin: &AdminCap, attrs: &mut TallyAttributes, nft_ids: vector<u64>, urls: vector<String>, ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&nft_ids);
        while (i < len) {
            let id = *vector::borrow(&nft_ids, i);
            let url = *vector::borrow(&urls, i);
            add_url(admin, attrs, id, url, ctx);
            i = i + 1;
        }
    }

    public entry fun remove_attributes(_: &AdminCap, attrs: &mut TallyAttributes, nft_ids: vector<u64>, _ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&nft_ids);
        while (i < len) {
            let id = *vector::borrow(&nft_ids, i);
            let _ = table::remove(&mut attrs.nft_attributes, id);
            i = i + 1;
        }
    }

    public entry fun remove_urls(_: &AdminCap, attrs: &mut TallyAttributes, nft_ids: vector<u64>, _ctx: &mut TxContext) {
        let mut i = 0;
        let len = vector::length(&nft_ids);
        while (i < len) {
            let id = *vector::borrow(&nft_ids, i);
            let _ = table::remove(&mut attrs.nft_urls, id);
            i = i + 1;
        }
    }

    // --- User Reveal Function ---

    public entry fun reveal_nft(
        attrs: &mut TallyAttributes, 
        kiosk_id: ID, 
        kiosk: &mut Kiosk, 
        cap: &KioskOwnerCap, 
        _ctx: &mut TxContext
    ) {
        assert!(attrs.can_reveal, ENotStarted);
        
        // Borrow NFT from Kiosk
        let tally = kiosk::borrow_mut<Tally>(kiosk, cap, kiosk_id);
        
        assert!(!table::contains(&attrs.revealed_nfts, tally.number), EAlreadyRevealed);

        // Get attributes from registry
        let stored_attributes = table::borrow(&attrs.nft_attributes, tally.number);
        
        // Copy attributes to NFT
        let mut i = 0;
        let len = vec_map::size(stored_attributes);
        while (i < len) {
            let (key, value) = vec_map::get_entry_by_idx(stored_attributes, i);
            vec_map::insert(&mut tally.attributes, *key, *value);
            i = i + 1;
        };

        // Update URL
        let new_url = table::borrow(&attrs.nft_urls, tally.number);
        tally.url = *new_url;

        // Mark as revealed
        table::add(&mut attrs.revealed_nfts, tally.number, true);
    }

    public entry fun start_revealing(_: &AdminCap, attrs: &mut TallyAttributes, _ctx: &mut TxContext) {
        attrs.can_reveal = true;
    }

    // --- Burning Tickets ---

    public entry fun burn_free_ticket(ticket: TallyFreeTicket, _ctx: &mut TxContext) {
        let TallyFreeTicket { id } = ticket;
        object::delete(id);
    }

    public entry fun burn_early_ticket(ticket: TallyEarlyTicket, _ctx: &mut TxContext) {
        let TallyEarlyTicket { id } = ticket;
        object::delete(id);
    }

    // --- Withdrawals ---

    public entry fun withdraw_balance(_: &AdminCap, registry: &mut TallyRegistry, ctx: &mut TxContext) {
        let amt = balance::withdraw_all(&mut registry.balance);
        let coin = coin::from_balance(amt, ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    public entry fun withdraw_royalties(_: &AdminCap, policy: &mut TransferPolicy<Tally>, cap: &TransferPolicyCap<Tally>, ctx: &mut TxContext) {
        let coin = transfer_policy::withdraw(policy, cap, option::none(), ctx);
        transfer::public_transfer(coin, tx_context::sender(ctx));
    }

    // --- Internal Helpers ---

    fun mint(
        registry: &mut TallyRegistry,
        quantity: u64,
        access_type: EarlyAccess,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        check_can_public_mint(registry, quantity, sender, &access_type);

        let mut i = 0;
        while (i < quantity) {
            let number = registry.minted + 1;
            
            // Create NFT
            let tally = Tally {
                id: object::new(ctx),
                number: number,
                description: string::utf8(b"Forged in the heart of the Talus Kingdom, Tally NFTs grant their bearers the mantle of guardians, shaping the fate of AI agents on Sui and guiding its next great evolution"),
                url: url::new_unsafe_from_bytes(b"https://tallys.talus.network/unminted.png"),
                attributes: vec_map::empty()
            };

            registry.minted = registry.minted + 1;

            // Lock in Kiosk immediately
            kiosk::lock(kiosk, cap, policy, tally);
            
            i = i + 1;
        };
        
        add_addresses_minted(registry, sender, quantity);
    }

    fun admin_mint(
        registry: &mut TallyRegistry,
        quantity: u64,
        policy: &TransferPolicy<Tally>,
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        ctx: &mut TxContext
    ) {
        assert!(registry.minted + quantity <= registry.collection_size, EMintedOut);
        
        let mut i = 0;
        while (i < quantity) {
            let number = registry.minted + 1;
            let tally = Tally {
                id: object::new(ctx),
                number: number,
                description: string::utf8(b"Forged in the heart of the Talus Kingdom, Tally NFTs grant their bearers the mantle of guardians, shaping the fate of AI agents on Sui and guiding its next great evolution"),
                url: url::new_unsafe_from_bytes(b"https://tallys.talus.network/unminted.png"),
                attributes: vec_map::empty()
            };
            registry.minted = registry.minted + 1;
            kiosk::lock(kiosk, cap, policy, tally);
            i = i + 1;
        };

        add_addresses_minted(registry, tx_context::sender(ctx), quantity);
    }

    fun check_can_public_mint(registry: &TallyRegistry, quantity: u64, sender: address, access_type: &EarlyAccess) {
        if (access_type == &EarlyAccess::No) {
            assert!(registry.can_public_mint, ENotStarted);
        };
        assert!(registry.minted + quantity <= registry.collection_size, EMintedOut);
        
        let valid_quantity = if (quantity > 0 && quantity <= MAX_MINT_PER_TX) { true } else { false };
        assert!(valid_quantity, EAmountLimit);

        check_max_nfts_per_address(registry, sender, quantity);
    }

    fun add_addresses_minted(registry: &mut TallyRegistry, sender: address, quantity: u64) {
        if (table::contains(&registry.addresses_minted, sender)) {
            let minted_ref = table::borrow_mut(&mut registry.addresses_minted, sender);
            *minted_ref = *minted_ref + quantity;
        } else {
            table::add(&mut registry.addresses_minted, sender, quantity);
        }
    }

    fun check_max_nfts_per_address(registry: &TallyRegistry, sender: address, quantity: u64) {
        if (table::contains(&registry.addresses_minted, sender)) {
            let current_minted = table::borrow(&registry.addresses_minted, sender);
            assert!(*current_minted + quantity <= registry.max_nfts_per_address, EAmountLimit);
        }
    }

    fun has_mint_left(registry: &TallyRegistry, sender: address): bool {
        if (table::contains(&registry.addresses_minted, sender)) {
            let minted = table::borrow(&registry.addresses_minted, sender);
            *minted < registry.max_nfts_per_address
        } else {
            true
        }
    }

    // --- Getters ---

    public fun number(tally: &Tally): &u64 { &tally.number }
    public fun description(tally: &Tally): &String { &tally.description }
    public fun url(tally: &Tally): &Url { &tally.url }
    public fun attributes(tally: &Tally): &VecMap<String, String> { &tally.attributes }
    
    public fun balance(registry: &TallyRegistry): &Balance<SUI> { &registry.balance }
    public fun minted(registry: &TallyRegistry): &u64 { &registry.minted }
    public fun collection_size(registry: &TallyRegistry): &u64 { &registry.collection_size }
    public fun can_public_mint(registry: &TallyRegistry): &bool { &registry.can_public_mint }
    public fun max_nfts_per_address(registry: &TallyRegistry): &u64 { &registry.max_nfts_per_address }
    public fun addresses_minted(registry: &TallyRegistry): &Table<address, u64> { &registry.addresses_minted }
    public fun public_mint_price(registry: &TallyRegistry): &u64 { &registry.public_mint_price }
    public fun early_mints(registry: &TallyRegistry): &u64 { &registry.early_mints }
    public fun early_mints_used(registry: &TallyRegistry): &u64 { &registry.early_mints_used }
    public fun free_mints(registry: &TallyRegistry): &u64 { &registry.free_mints }
    public fun free_mints_used(registry: &TallyRegistry): &u64 { &registry.free_mints_used }
}
