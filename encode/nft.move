// Move bytecode v7
module 75888defd3f392d276643932ae204cd85337a5b8f04335f9f912b6291149f423.nft {
use 434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879::kiosk_lock_rule;
use 434b5bd8f6a7b05fede0ff46c6e511d71ea326ed38056e3bcd681d2d7c2a7879::royalty_rule;
use 0000000000000000000000000000000000000000000000000000000000000001::option;
use 0000000000000000000000000000000000000000000000000000000000000001::string;
use 0000000000000000000000000000000000000000000000000000000000000002::balance;
use 0000000000000000000000000000000000000000000000000000000000000002::coin;
use 0000000000000000000000000000000000000000000000000000000000000002::display;
use 0000000000000000000000000000000000000000000000000000000000000002::kiosk;
use 0000000000000000000000000000000000000000000000000000000000000002::object;
use 0000000000000000000000000000000000000000000000000000000000000002::package;
use 0000000000000000000000000000000000000000000000000000000000000002::sui;
use 0000000000000000000000000000000000000000000000000000000000000002::table;
use 0000000000000000000000000000000000000000000000000000000000000002::transfer;
use 0000000000000000000000000000000000000000000000000000000000000002::transfer_policy;
use 0000000000000000000000000000000000000000000000000000000000000002::tx_context;
use 0000000000000000000000000000000000000000000000000000000000000002::url;
use 0000000000000000000000000000000000000000000000000000000000000002::vec_map;

struct NFT has drop {
	dummy_field: bool
}

struct Tally has store, key {
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

struct AdminCap has store, key {
	id: UID
}

struct TradeDisabledRule has drop {
	dummy_field: bool
}

enum EarlyAccess has drop {
	Yes {  },
	No {  }
}

init(Arg0: NFT, Arg1: &mut TxContext) {
L2:	loc0: TallyAttributes
L3:	loc1: Display<Tally>
L4:	loc2: Display<TallyEarlyTicket>
L5:	loc3: Display<TallyFreeTicket>
L6:	loc4: Display<TallyRegistry>
L7:	loc5: Display<TallyAttributes>
L8:	loc6: vector<String>
L9:	loc7: vector<String>
L10:	loc8: vector<String>
L11:	loc9: vector<String>
L12:	loc10: vector<String>
L13:	loc11: TransferPolicy<Tally>
L14:	loc12: TransferPolicyCap<Tally>
L15:	loc13: Publisher
L16:	loc14: TallyRegistry
L17:	loc15: vector<String>
L18:	loc16: vector<String>
L19:	loc17: vector<String>
L20:	loc18: vector<String>
L21:	loc19: vector<String>
B0:
	0: MoveLoc[0](Arg0: NFT)
	1: CopyLoc[1](Arg1: &mut TxContext)
	2: Call package::claim<NFT>(NFT, &mut TxContext): Publisher
	3: StLoc[15](loc13: Publisher)
	4: LdConst[22](vector<u8>: "nam..)
	5: Call string::utf8(vector<u8>): String
	6: LdConst[23](vector<u8>: "des..)
	7: Call string::utf8(vector<u8>): String
	8: LdConst[24](vector<u8>: "ima..)
	9: Call string::utf8(vector<u8>): String
	10: LdConst[25](vector<u8>: "att..)
	11: Call string::utf8(vector<u8>): String
	12: LdConst[26](vector<u8>: "pro..)
	13: Call string::utf8(vector<u8>): String
	14: LdConst[27](vector<u8>: "cre..)
	15: Call string::utf8(vector<u8>): String
	16: VecPack(39, 6)
	17: StLoc[8](loc6: vector<String>)
	18: LdConst[28](vector<u8>: "Tal..)
	19: Call string::utf8(vector<u8>): String
	20: LdConst[29](vector<u8>: "{de..)
	21: Call string::utf8(vector<u8>): String
	22: LdConst[30](vector<u8>: "{ur..)
	23: Call string::utf8(vector<u8>): String
	24: LdConst[31](vector<u8>: "{at..)
	25: Call string::utf8(vector<u8>): String
	26: LdConst[15](vector<u8>: "htt..)
	27: Call string::utf8(vector<u8>): String
	28: LdConst[14](vector<u8>: "Tal..)
	29: Call string::utf8(vector<u8>): String
	30: VecPack(39, 6)
	31: StLoc[17](loc15: vector<String>)
	32: ImmBorrowLoc[15](loc13: Publisher)
	33: MoveLoc[8](loc6: vector<String>)
	34: MoveLoc[17](loc15: vector<String>)
	35: CopyLoc[1](Arg1: &mut TxContext)
	36: Call display::new_with_fields<Tally>(&Publisher, vector<String>, vector<String>, &mut TxContext): Display<Tally>
	37: StLoc[3](loc1: Display<Tally>)
	38: MutBorrowLoc[3](loc1: Display<Tally>)
	39: Call display::update_version<Tally>(&mut Display<Tally>)
	40: MoveLoc[3](loc1: Display<Tally>)
	41: CopyLoc[1](Arg1: &mut TxContext)
	42: FreezeRef
	43: Call tx_context::sender(&TxContext): address
	44: Call transfer::public_transfer<Display<Tally>>(Display<Tally>, address)
	45: LdConst[22](vector<u8>: "nam..)
	46: Call string::utf8(vector<u8>): String
	47: LdConst[23](vector<u8>: "des..)
	48: Call string::utf8(vector<u8>): String
	49: LdConst[24](vector<u8>: "ima..)
	50: Call string::utf8(vector<u8>): String
	51: LdConst[26](vector<u8>: "pro..)
	52: Call string::utf8(vector<u8>): String
	53: LdConst[27](vector<u8>: "cre..)
	54: Call string::utf8(vector<u8>): String
	55: VecPack(39, 5)
	56: StLoc[9](loc7: vector<String>)
	57: LdConst[32](vector<u8>: "Tal..)
	58: Call string::utf8(vector<u8>): String
	59: LdConst[33](vector<u8>: "Thi..)
	60: Call string::utf8(vector<u8>): String
	61: LdConst[13](vector<u8>: "htt..)
	62: Call string::utf8(vector<u8>): String
	63: LdConst[15](vector<u8>: "htt..)
	64: Call string::utf8(vector<u8>): String
	65: LdConst[14](vector<u8>: "Tal..)
	66: Call string::utf8(vector<u8>): String
	67: VecPack(39, 5)
	68: StLoc[18](loc16: vector<String>)
	69: ImmBorrowLoc[15](loc13: Publisher)
	70: MoveLoc[9](loc7: vector<String>)
	71: MoveLoc[18](loc16: vector<String>)
	72: CopyLoc[1](Arg1: &mut TxContext)
	73: Call display::new_with_fields<TallyEarlyTicket>(&Publisher, vector<String>, vector<String>, &mut TxContext): Display<TallyEarlyTicket>
	74: StLoc[4](loc2: Display<TallyEarlyTicket>)
	75: MutBorrowLoc[4](loc2: Display<TallyEarlyTicket>)
	76: Call display::update_version<TallyEarlyTicket>(&mut Display<TallyEarlyTicket>)
	77: MoveLoc[4](loc2: Display<TallyEarlyTicket>)
	78: CopyLoc[1](Arg1: &mut TxContext)
	79: FreezeRef
	80: Call tx_context::sender(&TxContext): address
	81: Call transfer::public_transfer<Display<TallyEarlyTicket>>(Display<TallyEarlyTicket>, address)
	82: LdConst[22](vector<u8>: "nam..)
	83: Call string::utf8(vector<u8>): String
	84: LdConst[23](vector<u8>: "des..)
	85: Call string::utf8(vector<u8>): String
	86: LdConst[24](vector<u8>: "ima..)
	87: Call string::utf8(vector<u8>): String
	88: LdConst[26](vector<u8>: "pro..)
	89: Call string::utf8(vector<u8>): String
	90: LdConst[27](vector<u8>: "cre..)
	91: Call string::utf8(vector<u8>): String
	92: VecPack(39, 5)
	93: StLoc[10](loc8: vector<String>)
	94: LdConst[34](vector<u8>: "Tal..)
	95: Call string::utf8(vector<u8>): String
	96: LdConst[35](vector<u8>: "Thi..)
	97: Call string::utf8(vector<u8>): String
	98: LdConst[13](vector<u8>: "htt..)
	99: Call string::utf8(vector<u8>): String
	100: LdConst[15](vector<u8>: "htt..)
	101: Call string::utf8(vector<u8>): String
	102: LdConst[14](vector<u8>: "Tal..)
	103: Call string::utf8(vector<u8>): String
	104: VecPack(39, 5)
	105: StLoc[19](loc17: vector<String>)
	106: ImmBorrowLoc[15](loc13: Publisher)
	107: MoveLoc[10](loc8: vector<String>)
	108: MoveLoc[19](loc17: vector<String>)
	109: CopyLoc[1](Arg1: &mut TxContext)
	110: Call display::new_with_fields<TallyFreeTicket>(&Publisher, vector<String>, vector<String>, &mut TxContext): Display<TallyFreeTicket>
	111: StLoc[5](loc3: Display<TallyFreeTicket>)
	112: MutBorrowLoc[5](loc3: Display<TallyFreeTicket>)
	113: Call display::update_version<TallyFreeTicket>(&mut Display<TallyFreeTicket>)
	114: MoveLoc[5](loc3: Display<TallyFreeTicket>)
	115: CopyLoc[1](Arg1: &mut TxContext)
	116: FreezeRef
	117: Call tx_context::sender(&TxContext): address
	118: Call transfer::public_transfer<Display<TallyFreeTicket>>(Display<TallyFreeTicket>, address)
	119: CopyLoc[1](Arg1: &mut TxContext)
	120: Call object::new(&mut TxContext): UID
	121: Call balance::zero<SUI>(): Balance<SUI>
	122: LdU64(0)
	123: LdConst[16](u64: 5555)
	124: LdFalse
	125: LdConst[17](u64: 2)
	126: CopyLoc[1](Arg1: &mut TxContext)
	127: Call table::new<address, u64>(&mut TxContext): Table<address, u64>
	128: LdConst[18](u64: 3300..)
	129: LdConst[19](u64: 5000..)
	130: LdU64(0)
	131: LdU64(0)
	132: LdU64(0)
	133: LdU64(0)
	134: Pack[4](TallyRegistry)
	135: StLoc[16](loc14: TallyRegistry)
	136: LdConst[22](vector<u8>: "nam..)
	137: Call string::utf8(vector<u8>): String
	138: LdConst[26](vector<u8>: "pro..)
	139: Call string::utf8(vector<u8>): String
	140: LdConst[27](vector<u8>: "cre..)
	141: Call string::utf8(vector<u8>): String
	142: VecPack(39, 3)
	143: StLoc[11](loc9: vector<String>)
	144: LdConst[36](vector<u8>: "Tal..)
	145: Call string::utf8(vector<u8>): String
	146: LdConst[15](vector<u8>: "htt..)
	147: Call string::utf8(vector<u8>): String
	148: LdConst[14](vector<u8>: "Tal..)
	149: Call string::utf8(vector<u8>): String
	150: VecPack(39, 3)
	151: StLoc[20](loc18: vector<String>)
	152: ImmBorrowLoc[15](loc13: Publisher)
	153: MoveLoc[11](loc9: vector<String>)
	154: MoveLoc[20](loc18: vector<String>)
	155: CopyLoc[1](Arg1: &mut TxContext)
	156: Call display::new_with_fields<TallyRegistry>(&Publisher, vector<String>, vector<String>, &mut TxContext): Display<TallyRegistry>
	157: StLoc[6](loc4: Display<TallyRegistry>)
	158: MutBorrowLoc[6](loc4: Display<TallyRegistry>)
	159: Call display::update_version<TallyRegistry>(&mut Display<TallyRegistry>)
	160: MoveLoc[6](loc4: Display<TallyRegistry>)
	161: CopyLoc[1](Arg1: &mut TxContext)
	162: FreezeRef
	163: Call tx_context::sender(&TxContext): address
	164: Call transfer::public_transfer<Display<TallyRegistry>>(Display<TallyRegistry>, address)
	165: CopyLoc[1](Arg1: &mut TxContext)
	166: Call object::new(&mut TxContext): UID
	167: CopyLoc[1](Arg1: &mut TxContext)
	168: Call table::new<u64, VecMap<String, String>>(&mut TxContext): Table<u64, VecMap<String, String>>
	169: CopyLoc[1](Arg1: &mut TxContext)
	170: Call table::new<u64, Url>(&mut TxContext): Table<u64, Url>
	171: CopyLoc[1](Arg1: &mut TxContext)
	172: Call table::new<u64, bool>(&mut TxContext): Table<u64, bool>
	173: LdFalse
	174: Pack[5](TallyAttributes)
	175: StLoc[2](loc0: TallyAttributes)
	176: LdConst[22](vector<u8>: "nam..)
	177: Call string::utf8(vector<u8>): String
	178: LdConst[26](vector<u8>: "pro..)
	179: Call string::utf8(vector<u8>): String
	180: LdConst[27](vector<u8>: "cre..)
	181: Call string::utf8(vector<u8>): String
	182: VecPack(39, 3)
	183: StLoc[12](loc10: vector<String>)
	184: LdConst[37](vector<u8>: "Tal..)
	185: Call string::utf8(vector<u8>): String
	186: LdConst[15](vector<u8>: "htt..)
	187: Call string::utf8(vector<u8>): String
	188: LdConst[14](vector<u8>: "Tal..)
	189: Call string::utf8(vector<u8>): String
	190: VecPack(39, 3)
	191: StLoc[21](loc19: vector<String>)
	192: ImmBorrowLoc[15](loc13: Publisher)
	193: MoveLoc[12](loc10: vector<String>)
	194: MoveLoc[21](loc19: vector<String>)
	195: CopyLoc[1](Arg1: &mut TxContext)
	196: Call display::new_with_fields<TallyAttributes>(&Publisher, vector<String>, vector<String>, &mut TxContext): Display<TallyAttributes>
	197: StLoc[7](loc5: Display<TallyAttributes>)
	198: MutBorrowLoc[7](loc5: Display<TallyAttributes>)
	199: Call display::update_version<TallyAttributes>(&mut Display<TallyAttributes>)
	200: MoveLoc[7](loc5: Display<TallyAttributes>)
	201: CopyLoc[1](Arg1: &mut TxContext)
	202: FreezeRef
	203: Call tx_context::sender(&TxContext): address
	204: Call transfer::public_transfer<Display<TallyAttributes>>(Display<TallyAttributes>, address)
	205: CopyLoc[1](Arg1: &mut TxContext)
	206: Call object::new(&mut TxContext): UID
	207: Pack[6](AdminCap)
	208: CopyLoc[1](Arg1: &mut TxContext)
	209: FreezeRef
	210: Call tx_context::sender(&TxContext): address
	211: Call transfer::transfer<AdminCap>(AdminCap, address)
	212: ImmBorrowLoc[15](loc13: Publisher)
	213: CopyLoc[1](Arg1: &mut TxContext)
	214: Call transfer_policy::new<Tally>(&Publisher, &mut TxContext): TransferPolicy<Tally> * TransferPolicyCap<Tally>
	215: StLoc[14](loc12: TransferPolicyCap<Tally>)
	216: StLoc[13](loc11: TransferPolicy<Tally>)
	217: MutBorrowLoc[13](loc11: TransferPolicy<Tally>)
	218: ImmBorrowLoc[14](loc12: TransferPolicyCap<Tally>)
	219: Call kiosk_lock_rule::add<Tally>(&mut TransferPolicy<Tally>, &TransferPolicyCap<Tally>)
	220: MutBorrowLoc[13](loc11: TransferPolicy<Tally>)
	221: ImmBorrowLoc[14](loc12: TransferPolicyCap<Tally>)
	222: LdConst[21](u16: 100)
	223: LdU64(0)
	224: Call royalty_rule::add<Tally>(&mut TransferPolicy<Tally>, &TransferPolicyCap<Tally>, u16, u64)
	225: LdFalse
	226: Pack[7](TradeDisabledRule)
	227: MutBorrowLoc[13](loc11: TransferPolicy<Tally>)
	228: ImmBorrowLoc[14](loc12: TransferPolicyCap<Tally>)
	229: LdConst[38](vector<u8>: "no_..)
	230: Call transfer_policy::add_rule<Tally, TradeDisabledRule, vector<u8>>(TradeDisabledRule, &mut TransferPolicy<Tally>, &TransferPolicyCap<Tally>, vector<u8>)
	231: MoveLoc[13](loc11: TransferPolicy<Tally>)
	232: Call transfer::public_share_object<TransferPolicy<Tally>>(TransferPolicy<Tally>)
	233: MoveLoc[14](loc12: TransferPolicyCap<Tally>)
	234: CopyLoc[1](Arg1: &mut TxContext)
	235: FreezeRef
	236: Call tx_context::sender(&TxContext): address
	237: Call transfer::public_transfer<TransferPolicyCap<Tally>>(TransferPolicyCap<Tally>, address)
	238: MoveLoc[15](loc13: Publisher)
	239: MoveLoc[1](Arg1: &mut TxContext)
	240: FreezeRef
	241: Call tx_context::sender(&TxContext): address
	242: Call transfer::public_transfer<Publisher>(Publisher, address)
	243: MoveLoc[16](loc14: TallyRegistry)
	244: Call transfer::share_object<TallyRegistry>(TallyRegistry)
	245: MoveLoc[2](loc0: TallyAttributes)
	246: Call transfer::share_object<TallyAttributes>(TallyAttributes)
	247: Ret
}

entry public start_minting(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: &mut TxContext) {
B0:
	0: LdTrue
	1: MoveLoc[1](Arg1: &mut TallyRegistry)
	2: MutBorrowField[0](TallyRegistry.can_public_mint: bool)
	3: WriteRef
	4: Ret
}

entry public stop_minting(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: &mut TxContext) {
B0:
	0: LdFalse
	1: MoveLoc[1](Arg1: &mut TallyRegistry)
	2: MutBorrowField[0](TallyRegistry.can_public_mint: bool)
	3: WriteRef
	4: Ret
}

entry public start_trading(Arg0: &AdminCap, Arg1: &mut TransferPolicy<Tally>, Arg2: &TransferPolicyCap<Tally>, Arg3: &mut TxContext) {
B0:
	0: MoveLoc[1](Arg1: &mut TransferPolicy<Tally>)
	1: MoveLoc[2](Arg2: &TransferPolicyCap<Tally>)
	2: Call transfer_policy::remove_rule<Tally, TradeDisabledRule, vector<u8>>(&mut TransferPolicy<Tally>, &TransferPolicyCap<Tally>)
	3: Ret
}

entry public distribute_free_tickets(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: vector<address>, Arg3: &mut TxContext) {
L4:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[4](loc0: u64)
B1:
	2: CopyLoc[4](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<address>)
	4: VecLen(45)
	5: Lt
	6: BrFalse(21)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[3](Arg3: &mut TxContext)
	9: Call object::new(&mut TxContext): UID
	10: Pack[3](TallyFreeTicket)
	11: ImmBorrowLoc[2](Arg2: vector<address>)
	12: CopyLoc[4](loc0: u64)
	13: VecImmBorrow(45)
	14: ReadRef
	15: Call transfer::transfer<TallyFreeTicket>(TallyFreeTicket, address)
	16: MoveLoc[4](loc0: u64)
	17: LdU64(1)
	18: Add
	19: StLoc[4](loc0: u64)
	20: Branch(2)
B4:
	21: MoveLoc[3](Arg3: &mut TxContext)
	22: Pop
	23: CopyLoc[1](Arg1: &mut TallyRegistry)
	24: ImmBorrowField[1](TallyRegistry.free_mints: u64)
	25: ReadRef
	26: ImmBorrowLoc[2](Arg2: vector<address>)
	27: VecLen(45)
	28: LdConst[20](u64: 1)
	29: Mul
	30: Add
	31: MoveLoc[1](Arg1: &mut TallyRegistry)
	32: MutBorrowField[1](TallyRegistry.free_mints: u64)
	33: WriteRef
	34: Ret
}

entry public distribute_early_tickets(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: vector<address>, Arg3: &mut TxContext) {
L4:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[4](loc0: u64)
B1:
	2: CopyLoc[4](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<address>)
	4: VecLen(45)
	5: Lt
	6: BrFalse(21)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[3](Arg3: &mut TxContext)
	9: Call object::new(&mut TxContext): UID
	10: Pack[2](TallyEarlyTicket)
	11: ImmBorrowLoc[2](Arg2: vector<address>)
	12: CopyLoc[4](loc0: u64)
	13: VecImmBorrow(45)
	14: ReadRef
	15: Call transfer::transfer<TallyEarlyTicket>(TallyEarlyTicket, address)
	16: MoveLoc[4](loc0: u64)
	17: LdU64(1)
	18: Add
	19: StLoc[4](loc0: u64)
	20: Branch(2)
B4:
	21: MoveLoc[3](Arg3: &mut TxContext)
	22: Pop
	23: CopyLoc[1](Arg1: &mut TallyRegistry)
	24: ImmBorrowField[2](TallyRegistry.early_mints: u64)
	25: ReadRef
	26: ImmBorrowLoc[2](Arg2: vector<address>)
	27: VecLen(45)
	28: LdConst[20](u64: 1)
	29: Mul
	30: Add
	31: MoveLoc[1](Arg1: &mut TallyRegistry)
	32: MutBorrowField[2](TallyRegistry.early_mints: u64)
	33: WriteRef
	34: Ret
}

entry public mint_tally(Arg0: &mut TallyRegistry, Arg1: u64, Arg2: Coin<SUI>, Arg3: &TransferPolicy<Tally>, Arg4: &mut Kiosk, Arg5: &KioskOwnerCap, Arg6: &mut TxContext) {
L7:	loc0: Coin<SUI>
L8:	loc1: u64
B0:
	0: CopyLoc[1](Arg1: u64)
	1: CopyLoc[0](Arg0: &mut TallyRegistry)
	2: ImmBorrowField[3](TallyRegistry.public_mint_price: u64)
	3: ReadRef
	4: Mul
	5: StLoc[8](loc1: u64)
	6: ImmBorrowLoc[2](Arg2: Coin<SUI>)
	7: Call coin::value<SUI>(&Coin<SUI>): u64
	8: CopyLoc[8](loc1: u64)
	9: Ge
	10: BrFalse(12)
B1:
	11: Branch(24)
B2:
	12: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	13: Pop
	14: MoveLoc[0](Arg0: &mut TallyRegistry)
	15: Pop
	16: MoveLoc[5](Arg5: &KioskOwnerCap)
	17: Pop
	18: MoveLoc[4](Arg4: &mut Kiosk)
	19: Pop
	20: MoveLoc[6](Arg6: &mut TxContext)
	21: Pop
	22: LdU64(9223373750546726913)
	23: Abort
B3:
	24: MutBorrowLoc[2](Arg2: Coin<SUI>)
	25: MoveLoc[8](loc1: u64)
	26: CopyLoc[6](Arg6: &mut TxContext)
	27: Call coin::split<SUI>(&mut Coin<SUI>, u64, &mut TxContext): Coin<SUI>
	28: StLoc[7](loc0: Coin<SUI>)
	29: CopyLoc[0](Arg0: &mut TallyRegistry)
	30: MutBorrowField[4](TallyRegistry.balance: Balance<SUI>)
	31: MoveLoc[7](loc0: Coin<SUI>)
	32: Call coin::into_balance<SUI>(Coin<SUI>): Balance<SUI>
	33: Call balance::join<SUI>(&mut Balance<SUI>, Balance<SUI>): u64
	34: Pop
	35: ImmBorrowLoc[2](Arg2: Coin<SUI>)
	36: Call coin::value<SUI>(&Coin<SUI>): u64
	37: LdU64(0)
	38: Gt
	39: BrFalse(46)
B4:
	40: MoveLoc[2](Arg2: Coin<SUI>)
	41: CopyLoc[6](Arg6: &mut TxContext)
	42: FreezeRef
	43: Call tx_context::sender(&TxContext): address
	44: Call transfer::public_transfer<Coin<SUI>>(Coin<SUI>, address)
	45: Branch(48)
B5:
	46: MoveLoc[2](Arg2: Coin<SUI>)
	47: Call coin::destroy_zero<SUI>(Coin<SUI>)
B6:
	48: MoveLoc[0](Arg0: &mut TallyRegistry)
	49: MoveLoc[1](Arg1: u64)
	50: PackVariant(VariantHandleIndex(0))
	51: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	52: MoveLoc[4](Arg4: &mut Kiosk)
	53: MoveLoc[5](Arg5: &KioskOwnerCap)
	54: MoveLoc[6](Arg6: &mut TxContext)
	55: Call mint(&mut TallyRegistry, u64, EarlyAccess, &TransferPolicy<Tally>, &mut Kiosk, &KioskOwnerCap, &mut TxContext)
	56: Ret
}

entry public mint_tally_early(Arg0: &mut TallyRegistry, Arg1: u64, Arg2: Coin<SUI>, Arg3: TallyEarlyTicket, Arg4: &TransferPolicy<Tally>, Arg5: &mut Kiosk, Arg6: &KioskOwnerCap, Arg7: &mut TxContext) {
L8:	loc0: bool
L9:	loc1: Coin<SUI>
L10:	loc2: u64
B0:
	0: CopyLoc[1](Arg1: u64)
	1: LdConst[20](u64: 1)
	2: Le
	3: BrFalse(5)
B1:
	4: Branch(17)
B2:
	5: MoveLoc[4](Arg4: &TransferPolicy<Tally>)
	6: Pop
	7: MoveLoc[0](Arg0: &mut TallyRegistry)
	8: Pop
	9: MoveLoc[6](Arg6: &KioskOwnerCap)
	10: Pop
	11: MoveLoc[5](Arg5: &mut Kiosk)
	12: Pop
	13: MoveLoc[7](Arg7: &mut TxContext)
	14: Pop
	15: LdU64(9223373887986073607)
	16: Abort
B3:
	17: CopyLoc[1](Arg1: u64)
	18: CopyLoc[0](Arg0: &mut TallyRegistry)
	19: ImmBorrowField[5](TallyRegistry.discounted_mint_price: u64)
	20: ReadRef
	21: Mul
	22: StLoc[10](loc2: u64)
	23: ImmBorrowLoc[2](Arg2: Coin<SUI>)
	24: Call coin::value<SUI>(&Coin<SUI>): u64
	25: CopyLoc[10](loc2: u64)
	26: Ge
	27: BrFalse(29)
B4:
	28: Branch(41)
B5:
	29: MoveLoc[4](Arg4: &TransferPolicy<Tally>)
	30: Pop
	31: MoveLoc[0](Arg0: &mut TallyRegistry)
	32: Pop
	33: MoveLoc[6](Arg6: &KioskOwnerCap)
	34: Pop
	35: MoveLoc[5](Arg5: &mut Kiosk)
	36: Pop
	37: MoveLoc[7](Arg7: &mut TxContext)
	38: Pop
	39: LdU64(9223373913755484161)
	40: Abort
B6:
	41: MutBorrowLoc[2](Arg2: Coin<SUI>)
	42: MoveLoc[10](loc2: u64)
	43: CopyLoc[7](Arg7: &mut TxContext)
	44: Call coin::split<SUI>(&mut Coin<SUI>, u64, &mut TxContext): Coin<SUI>
	45: StLoc[9](loc1: Coin<SUI>)
	46: CopyLoc[0](Arg0: &mut TallyRegistry)
	47: MutBorrowField[4](TallyRegistry.balance: Balance<SUI>)
	48: MoveLoc[9](loc1: Coin<SUI>)
	49: Call coin::into_balance<SUI>(Coin<SUI>): Balance<SUI>
	50: Call balance::join<SUI>(&mut Balance<SUI>, Balance<SUI>): u64
	51: Pop
	52: ImmBorrowLoc[2](Arg2: Coin<SUI>)
	53: Call coin::value<SUI>(&Coin<SUI>): u64
	54: LdU64(0)
	55: Gt
	56: BrFalse(63)
B7:
	57: MoveLoc[2](Arg2: Coin<SUI>)
	58: CopyLoc[7](Arg7: &mut TxContext)
	59: FreezeRef
	60: Call tx_context::sender(&TxContext): address
	61: Call transfer::public_transfer<Coin<SUI>>(Coin<SUI>, address)
	62: Branch(65)
B8:
	63: MoveLoc[2](Arg2: Coin<SUI>)
	64: Call coin::destroy_zero<SUI>(Coin<SUI>)
B9:
	65: CopyLoc[0](Arg0: &mut TallyRegistry)
	66: CopyLoc[1](Arg1: u64)
	67: PackVariant(VariantHandleIndex(1))
	68: MoveLoc[4](Arg4: &TransferPolicy<Tally>)
	69: MoveLoc[5](Arg5: &mut Kiosk)
	70: MoveLoc[6](Arg6: &KioskOwnerCap)
	71: CopyLoc[7](Arg7: &mut TxContext)
	72: Call mint(&mut TallyRegistry, u64, EarlyAccess, &TransferPolicy<Tally>, &mut Kiosk, &KioskOwnerCap, &mut TxContext)
	73: CopyLoc[0](Arg0: &mut TallyRegistry)
	74: ImmBorrowField[6](TallyRegistry.early_mints_used: u64)
	75: ReadRef
	76: CopyLoc[1](Arg1: u64)
	77: Add
	78: CopyLoc[0](Arg0: &mut TallyRegistry)
	79: MutBorrowField[6](TallyRegistry.early_mints_used: u64)
	80: WriteRef
	81: MoveLoc[0](Arg0: &mut TallyRegistry)
	82: FreezeRef
	83: CopyLoc[7](Arg7: &mut TxContext)
	84: FreezeRef
	85: Call tx_context::sender(&TxContext): address
	86: Call has_mint_left(&TallyRegistry, address): bool
	87: Not
	88: BrFalse(92)
B10:
	89: LdTrue
	90: StLoc[8](loc0: bool)
	91: Branch(96)
B11:
	92: MoveLoc[1](Arg1: u64)
	93: LdConst[20](u64: 1)
	94: Ge
	95: StLoc[8](loc0: bool)
B12:
	96: MoveLoc[8](loc0: bool)
	97: BrFalse(104)
B13:
	98: MoveLoc[7](Arg7: &mut TxContext)
	99: Pop
	100: MoveLoc[3](Arg3: TallyEarlyTicket)
	101: Unpack[2](TallyEarlyTicket)
	102: Call object::delete(UID)
	103: Branch(109)
B14:
	104: MoveLoc[3](Arg3: TallyEarlyTicket)
	105: MoveLoc[7](Arg7: &mut TxContext)
	106: FreezeRef
	107: Call tx_context::sender(&TxContext): address
	108: Call transfer::transfer<TallyEarlyTicket>(TallyEarlyTicket, address)
B15:
	109: Ret
}

entry public mint_tally_free(Arg0: &mut TallyRegistry, Arg1: u64, Arg2: TallyFreeTicket, Arg3: &TransferPolicy<Tally>, Arg4: &mut Kiosk, Arg5: &KioskOwnerCap, Arg6: &mut TxContext) {
L7:	loc0: bool
B0:
	0: CopyLoc[1](Arg1: u64)
	1: LdConst[20](u64: 1)
	2: Le
	3: BrFalse(5)
B1:
	4: Branch(17)
B2:
	5: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	6: Pop
	7: MoveLoc[0](Arg0: &mut TallyRegistry)
	8: Pop
	9: MoveLoc[5](Arg5: &KioskOwnerCap)
	10: Pop
	11: MoveLoc[4](Arg4: &mut Kiosk)
	12: Pop
	13: MoveLoc[6](Arg6: &mut TxContext)
	14: Pop
	15: LdU64(9223374098439471111)
	16: Abort
B3:
	17: CopyLoc[0](Arg0: &mut TallyRegistry)
	18: CopyLoc[1](Arg1: u64)
	19: PackVariant(VariantHandleIndex(1))
	20: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	21: MoveLoc[4](Arg4: &mut Kiosk)
	22: MoveLoc[5](Arg5: &KioskOwnerCap)
	23: CopyLoc[6](Arg6: &mut TxContext)
	24: Call mint(&mut TallyRegistry, u64, EarlyAccess, &TransferPolicy<Tally>, &mut Kiosk, &KioskOwnerCap, &mut TxContext)
	25: CopyLoc[0](Arg0: &mut TallyRegistry)
	26: ImmBorrowField[7](TallyRegistry.free_mints_used: u64)
	27: ReadRef
	28: CopyLoc[1](Arg1: u64)
	29: Add
	30: CopyLoc[0](Arg0: &mut TallyRegistry)
	31: MutBorrowField[7](TallyRegistry.free_mints_used: u64)
	32: WriteRef
	33: MoveLoc[0](Arg0: &mut TallyRegistry)
	34: FreezeRef
	35: CopyLoc[6](Arg6: &mut TxContext)
	36: FreezeRef
	37: Call tx_context::sender(&TxContext): address
	38: Call has_mint_left(&TallyRegistry, address): bool
	39: Not
	40: BrFalse(44)
B4:
	41: LdTrue
	42: StLoc[7](loc0: bool)
	43: Branch(48)
B5:
	44: MoveLoc[1](Arg1: u64)
	45: LdConst[20](u64: 1)
	46: Ge
	47: StLoc[7](loc0: bool)
B6:
	48: MoveLoc[7](loc0: bool)
	49: BrFalse(56)
B7:
	50: MoveLoc[6](Arg6: &mut TxContext)
	51: Pop
	52: MoveLoc[2](Arg2: TallyFreeTicket)
	53: Unpack[3](TallyFreeTicket)
	54: Call object::delete(UID)
	55: Branch(61)
B8:
	56: MoveLoc[2](Arg2: TallyFreeTicket)
	57: MoveLoc[6](Arg6: &mut TxContext)
	58: FreezeRef
	59: Call tx_context::sender(&TxContext): address
	60: Call transfer::transfer<TallyFreeTicket>(TallyFreeTicket, address)
B9:
	61: Ret
}

entry public mint_tally_admin(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: u64, Arg3: &TransferPolicy<Tally>, Arg4: &mut Kiosk, Arg5: &KioskOwnerCap, Arg6: &mut TxContext) {
B0:
	0: MoveLoc[1](Arg1: &mut TallyRegistry)
	1: MoveLoc[2](Arg2: u64)
	2: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	3: MoveLoc[4](Arg4: &mut Kiosk)
	4: MoveLoc[5](Arg5: &KioskOwnerCap)
	5: MoveLoc[6](Arg6: &mut TxContext)
	6: Call admin_mint(&mut TallyRegistry, u64, &TransferPolicy<Tally>, &mut Kiosk, &KioskOwnerCap, &mut TxContext)
	7: Ret
}

entry public add_attributes(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: u64, Arg3: vector<String>, Arg4: vector<String>, Arg5: &mut TxContext) {
B0:
	0: CopyLoc[1](Arg1: &mut TallyAttributes)
	1: ImmBorrowField[8](TallyAttributes.nft_attributes: Table<u64, VecMap<String, String>>)
	2: CopyLoc[2](Arg2: u64)
	3: Call table::contains<u64, VecMap<String, String>>(&Table<u64, VecMap<String, String>>, u64): bool
	4: Not
	5: BrFalse(7)
B1:
	6: Branch(11)
B2:
	7: MoveLoc[1](Arg1: &mut TallyAttributes)
	8: Pop
	9: LdU64(9223374278828359691)
	10: Abort
B3:
	11: MoveLoc[1](Arg1: &mut TallyAttributes)
	12: MutBorrowField[8](TallyAttributes.nft_attributes: Table<u64, VecMap<String, String>>)
	13: MoveLoc[2](Arg2: u64)
	14: MoveLoc[3](Arg3: vector<String>)
	15: MoveLoc[4](Arg4: vector<String>)
	16: Call vec_map::from_keys_values<String, String>(vector<String>, vector<String>): VecMap<String, String>
	17: Call table::add<u64, VecMap<String, String>>(&mut Table<u64, VecMap<String, String>>, u64, VecMap<String, String>)
	18: Ret
}

entry public bulk_add_attributes(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: vector<u64>, Arg3: vector<vector<String>>, Arg4: vector<vector<String>>, Arg5: &mut TxContext) {
L6:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[6](loc0: u64)
B1:
	2: CopyLoc[6](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<u64>)
	4: VecLen(75)
	5: Lt
	6: BrFalse(29)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[0](Arg0: &AdminCap)
	9: CopyLoc[1](Arg1: &mut TallyAttributes)
	10: ImmBorrowLoc[2](Arg2: vector<u64>)
	11: CopyLoc[6](loc0: u64)
	12: VecImmBorrow(75)
	13: ReadRef
	14: ImmBorrowLoc[3](Arg3: vector<vector<String>>)
	15: CopyLoc[6](loc0: u64)
	16: VecImmBorrow(88)
	17: ReadRef
	18: ImmBorrowLoc[4](Arg4: vector<vector<String>>)
	19: CopyLoc[6](loc0: u64)
	20: VecImmBorrow(88)
	21: ReadRef
	22: CopyLoc[5](Arg5: &mut TxContext)
	23: Call add_attributes(&AdminCap, &mut TallyAttributes, u64, vector<String>, vector<String>, &mut TxContext)
	24: MoveLoc[6](loc0: u64)
	25: LdU64(1)
	26: Add
	27: StLoc[6](loc0: u64)
	28: Branch(2)
B4:
	29: MoveLoc[5](Arg5: &mut TxContext)
	30: Pop
	31: MoveLoc[1](Arg1: &mut TallyAttributes)
	32: Pop
	33: MoveLoc[0](Arg0: &AdminCap)
	34: Pop
	35: Ret
}

entry public add_url(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: u64, Arg3: String, Arg4: &mut TxContext) {
B0:
	0: CopyLoc[1](Arg1: &mut TallyAttributes)
	1: ImmBorrowField[9](TallyAttributes.nft_urls: Table<u64, Url>)
	2: CopyLoc[2](Arg2: u64)
	3: Call table::contains<u64, Url>(&Table<u64, Url>, u64): bool
	4: Not
	5: BrFalse(7)
B1:
	6: Branch(11)
B2:
	7: MoveLoc[1](Arg1: &mut TallyAttributes)
	8: Pop
	9: LdU64(9223374416267313163)
	10: Abort
B3:
	11: MoveLoc[1](Arg1: &mut TallyAttributes)
	12: MutBorrowField[9](TallyAttributes.nft_urls: Table<u64, Url>)
	13: MoveLoc[2](Arg2: u64)
	14: MoveLoc[3](Arg3: String)
	15: Call string::into_bytes(String): vector<u8>
	16: Call url::new_unsafe_from_bytes(vector<u8>): Url
	17: Call table::add<u64, Url>(&mut Table<u64, Url>, u64, Url)
	18: Ret
}

entry public bulk_add_urls(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: vector<u64>, Arg3: vector<String>, Arg4: &mut TxContext) {
L5:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[5](loc0: u64)
B1:
	2: CopyLoc[5](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<u64>)
	4: VecLen(75)
	5: Lt
	6: BrFalse(25)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[0](Arg0: &AdminCap)
	9: CopyLoc[1](Arg1: &mut TallyAttributes)
	10: ImmBorrowLoc[2](Arg2: vector<u64>)
	11: CopyLoc[5](loc0: u64)
	12: VecImmBorrow(75)
	13: ReadRef
	14: ImmBorrowLoc[3](Arg3: vector<String>)
	15: CopyLoc[5](loc0: u64)
	16: VecImmBorrow(39)
	17: ReadRef
	18: CopyLoc[4](Arg4: &mut TxContext)
	19: Call add_url(&AdminCap, &mut TallyAttributes, u64, String, &mut TxContext)
	20: MoveLoc[5](loc0: u64)
	21: LdU64(1)
	22: Add
	23: StLoc[5](loc0: u64)
	24: Branch(2)
B4:
	25: MoveLoc[4](Arg4: &mut TxContext)
	26: Pop
	27: MoveLoc[1](Arg1: &mut TallyAttributes)
	28: Pop
	29: MoveLoc[0](Arg0: &AdminCap)
	30: Pop
	31: Ret
}

entry public remove_attributes(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: vector<u64>, Arg3: &mut TxContext) {
L4:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[4](loc0: u64)
B1:
	2: CopyLoc[4](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<u64>)
	4: VecLen(75)
	5: Lt
	6: BrFalse(21)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[1](Arg1: &mut TallyAttributes)
	9: MutBorrowField[8](TallyAttributes.nft_attributes: Table<u64, VecMap<String, String>>)
	10: ImmBorrowLoc[2](Arg2: vector<u64>)
	11: CopyLoc[4](loc0: u64)
	12: VecImmBorrow(75)
	13: ReadRef
	14: Call table::remove<u64, VecMap<String, String>>(&mut Table<u64, VecMap<String, String>>, u64): VecMap<String, String>
	15: Pop
	16: MoveLoc[4](loc0: u64)
	17: LdU64(1)
	18: Add
	19: StLoc[4](loc0: u64)
	20: Branch(2)
B4:
	21: MoveLoc[1](Arg1: &mut TallyAttributes)
	22: Pop
	23: Ret
}

entry public remove_urls(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: vector<u64>, Arg3: &mut TxContext) {
L4:	loc0: u64
B0:
	0: LdU64(0)
	1: StLoc[4](loc0: u64)
B1:
	2: CopyLoc[4](loc0: u64)
	3: ImmBorrowLoc[2](Arg2: vector<u64>)
	4: VecLen(75)
	5: Lt
	6: BrFalse(21)
B2:
	7: Branch(8)
B3:
	8: CopyLoc[1](Arg1: &mut TallyAttributes)
	9: MutBorrowField[9](TallyAttributes.nft_urls: Table<u64, Url>)
	10: ImmBorrowLoc[2](Arg2: vector<u64>)
	11: CopyLoc[4](loc0: u64)
	12: VecImmBorrow(75)
	13: ReadRef
	14: Call table::remove<u64, Url>(&mut Table<u64, Url>, u64): Url
	15: Pop
	16: MoveLoc[4](loc0: u64)
	17: LdU64(1)
	18: Add
	19: StLoc[4](loc0: u64)
	20: Branch(2)
B4:
	21: MoveLoc[1](Arg1: &mut TallyAttributes)
	22: Pop
	23: Ret
}

entry public reveal_nft(Arg0: &mut TallyAttributes, Arg1: ID, Arg2: &mut Kiosk, Arg3: &KioskOwnerCap, Arg4: &mut TxContext) {
L5:	loc0: u64
L6:	loc1: &String
L7:	loc2: &mut Tally
L8:	loc3: &VecMap<String, String>
L9:	loc4: &String
B0:
	0: CopyLoc[0](Arg0: &mut TallyAttributes)
	1: ImmBorrowField[10](TallyAttributes.can_reveal: bool)
	2: ReadRef
	3: BrFalse(5)
B1:
	4: Branch(13)
B2:
	5: MoveLoc[3](Arg3: &KioskOwnerCap)
	6: Pop
	7: MoveLoc[2](Arg2: &mut Kiosk)
	8: Pop
	9: MoveLoc[0](Arg0: &mut TallyAttributes)
	10: Pop
	11: LdU64(9223374669669859331)
	12: Abort
B3:
	13: MoveLoc[2](Arg2: &mut Kiosk)
	14: MoveLoc[3](Arg3: &KioskOwnerCap)
	15: MoveLoc[1](Arg1: ID)
	16: Call kiosk::borrow_mut<Tally>(&mut Kiosk, &KioskOwnerCap, ID): &mut Tally
	17: StLoc[7](loc2: &mut Tally)
	18: CopyLoc[0](Arg0: &mut TallyAttributes)
	19: ImmBorrowField[11](TallyAttributes.revealed_nfts: Table<u64, bool>)
	20: CopyLoc[7](loc2: &mut Tally)
	21: ImmBorrowField[12](Tally.number: u64)
	22: ReadRef
	23: Call table::contains<u64, bool>(&Table<u64, bool>, u64): bool
	24: Not
	25: BrFalse(27)
B4:
	26: Branch(33)
B5:
	27: MoveLoc[7](loc2: &mut Tally)
	28: Pop
	29: MoveLoc[0](Arg0: &mut TallyAttributes)
	30: Pop
	31: LdU64(9223374691145089033)
	32: Abort
B6:
	33: CopyLoc[0](Arg0: &mut TallyAttributes)
	34: ImmBorrowField[8](TallyAttributes.nft_attributes: Table<u64, VecMap<String, String>>)
	35: CopyLoc[7](loc2: &mut Tally)
	36: ImmBorrowField[12](Tally.number: u64)
	37: ReadRef
	38: Call table::borrow<u64, VecMap<String, String>>(&Table<u64, VecMap<String, String>>, u64): &VecMap<String, String>
	39: StLoc[8](loc3: &VecMap<String, String>)
	40: LdU64(0)
	41: StLoc[5](loc0: u64)
B7:
	42: CopyLoc[5](loc0: u64)
	43: CopyLoc[8](loc3: &VecMap<String, String>)
	44: Call vec_map::size<String, String>(&VecMap<String, String>): u64
	45: Lt
	46: BrFalse(64)
B8:
	47: CopyLoc[8](loc3: &VecMap<String, String>)
	48: CopyLoc[5](loc0: u64)
	49: Call vec_map::get_entry_by_idx<String, String>(&VecMap<String, String>, u64): &String * &String
	50: StLoc[9](loc4: &String)
	51: StLoc[6](loc1: &String)
	52: CopyLoc[7](loc2: &mut Tally)
	53: MutBorrowField[13](Tally.attributes: VecMap<String, String>)
	54: MoveLoc[6](loc1: &String)
	55: ReadRef
	56: MoveLoc[9](loc4: &String)
	57: ReadRef
	58: Call vec_map::insert<String, String>(&mut VecMap<String, String>, String, String)
	59: MoveLoc[5](loc0: u64)
	60: LdU64(1)
	61: Add
	62: StLoc[5](loc0: u64)
	63: Branch(42)
B9:
	64: MoveLoc[8](loc3: &VecMap<String, String>)
	65: Pop
	66: CopyLoc[0](Arg0: &mut TallyAttributes)
	67: ImmBorrowField[9](TallyAttributes.nft_urls: Table<u64, Url>)
	68: CopyLoc[7](loc2: &mut Tally)
	69: ImmBorrowField[12](Tally.number: u64)
	70: ReadRef
	71: Call table::borrow<u64, Url>(&Table<u64, Url>, u64): &Url
	72: ReadRef
	73: CopyLoc[7](loc2: &mut Tally)
	74: MutBorrowField[14](Tally.url: Url)
	75: WriteRef
	76: MoveLoc[0](Arg0: &mut TallyAttributes)
	77: MutBorrowField[11](TallyAttributes.revealed_nfts: Table<u64, bool>)
	78: MoveLoc[7](loc2: &mut Tally)
	79: ImmBorrowField[12](Tally.number: u64)
	80: ReadRef
	81: LdTrue
	82: Call table::add<u64, bool>(&mut Table<u64, bool>, u64, bool)
	83: Ret
}

entry public start_revealing(Arg0: &AdminCap, Arg1: &mut TallyAttributes, Arg2: &mut TxContext) {
B0:
	0: LdTrue
	1: MoveLoc[1](Arg1: &mut TallyAttributes)
	2: MutBorrowField[10](TallyAttributes.can_reveal: bool)
	3: WriteRef
	4: Ret
}

entry public burn_free_ticket(Arg0: TallyFreeTicket, Arg1: &mut TxContext) {
B0:
	0: MoveLoc[0](Arg0: TallyFreeTicket)
	1: Unpack[3](TallyFreeTicket)
	2: Call object::delete(UID)
	3: Ret
}

entry public burn_early_ticket(Arg0: TallyEarlyTicket, Arg1: &mut TxContext) {
B0:
	0: MoveLoc[0](Arg0: TallyEarlyTicket)
	1: Unpack[2](TallyEarlyTicket)
	2: Call object::delete(UID)
	3: Ret
}

entry public withdraw_balance(Arg0: &AdminCap, Arg1: &mut TallyRegistry, Arg2: &mut TxContext) {
B0:
	0: MoveLoc[1](Arg1: &mut TallyRegistry)
	1: MutBorrowField[4](TallyRegistry.balance: Balance<SUI>)
	2: Call balance::withdraw_all<SUI>(&mut Balance<SUI>): Balance<SUI>
	3: CopyLoc[2](Arg2: &mut TxContext)
	4: Call coin::from_balance<SUI>(Balance<SUI>, &mut TxContext): Coin<SUI>
	5: MoveLoc[2](Arg2: &mut TxContext)
	6: FreezeRef
	7: Call tx_context::sender(&TxContext): address
	8: Call transfer::public_transfer<Coin<SUI>>(Coin<SUI>, address)
	9: Ret
}

entry public withdraw_royalties(Arg0: &AdminCap, Arg1: &mut TransferPolicy<Tally>, Arg2: &TransferPolicyCap<Tally>, Arg3: &mut TxContext) {
B0:
	0: MoveLoc[1](Arg1: &mut TransferPolicy<Tally>)
	1: MoveLoc[2](Arg2: &TransferPolicyCap<Tally>)
	2: Call option::none<u64>(): Option<u64>
	3: CopyLoc[3](Arg3: &mut TxContext)
	4: Call transfer_policy::withdraw<Tally>(&mut TransferPolicy<Tally>, &TransferPolicyCap<Tally>, Option<u64>, &mut TxContext): Coin<SUI>
	5: MoveLoc[3](Arg3: &mut TxContext)
	6: FreezeRef
	7: Call tx_context::sender(&TxContext): address
	8: Call transfer::public_transfer<Coin<SUI>>(Coin<SUI>, address)
	9: Ret
}

mint(Arg0: &mut TallyRegistry, Arg1: u64, Arg2: EarlyAccess, Arg3: &TransferPolicy<Tally>, Arg4: &mut Kiosk, Arg5: &KioskOwnerCap, Arg6: &mut TxContext) {
L7:	loc0: u64
L8:	loc1: Tally
B0:
	0: CopyLoc[0](Arg0: &mut TallyRegistry)
	1: FreezeRef
	2: CopyLoc[1](Arg1: u64)
	3: CopyLoc[6](Arg6: &mut TxContext)
	4: FreezeRef
	5: Call tx_context::sender(&TxContext): address
	6: ImmBorrowLoc[2](Arg2: EarlyAccess)
	7: Call check_can_public_mint(&TallyRegistry, u64, address, &EarlyAccess)
	8: LdU64(0)
	9: StLoc[7](loc0: u64)
B1:
	10: CopyLoc[7](loc0: u64)
	11: CopyLoc[1](Arg1: u64)
	12: Lt
	13: BrFalse(45)
B2:
	14: Branch(15)
B3:
	15: CopyLoc[6](Arg6: &mut TxContext)
	16: Call object::new(&mut TxContext): UID
	17: CopyLoc[0](Arg0: &mut TallyRegistry)
	18: ImmBorrowField[15](TallyRegistry.minted: u64)
	19: ReadRef
	20: LdConst[12](vector<u8>: "For..)
	21: Call string::utf8(vector<u8>): String
	22: LdConst[13](vector<u8>: "htt..)
	23: Call url::new_unsafe_from_bytes(vector<u8>): Url
	24: Call vec_map::empty<String, String>(): VecMap<String, String>
	25: Pack[1](Tally)
	26: StLoc[8](loc1: Tally)
	27: CopyLoc[0](Arg0: &mut TallyRegistry)
	28: ImmBorrowField[15](TallyRegistry.minted: u64)
	29: ReadRef
	30: LdU64(1)
	31: Add
	32: CopyLoc[0](Arg0: &mut TallyRegistry)
	33: MutBorrowField[15](TallyRegistry.minted: u64)
	34: WriteRef
	35: CopyLoc[4](Arg4: &mut Kiosk)
	36: CopyLoc[5](Arg5: &KioskOwnerCap)
	37: CopyLoc[3](Arg3: &TransferPolicy<Tally>)
	38: MoveLoc[8](loc1: Tally)
	39: Call kiosk::lock<Tally>(&mut Kiosk, &KioskOwnerCap, &TransferPolicy<Tally>, Tally)
	40: MoveLoc[7](loc0: u64)
	41: LdU64(1)
	42: Add
	43: StLoc[7](loc0: u64)
	44: Branch(10)
B4:
	45: MoveLoc[3](Arg3: &TransferPolicy<Tally>)
	46: Pop
	47: MoveLoc[5](Arg5: &KioskOwnerCap)
	48: Pop
	49: MoveLoc[4](Arg4: &mut Kiosk)
	50: Pop
	51: MoveLoc[0](Arg0: &mut TallyRegistry)
	52: MoveLoc[6](Arg6: &mut TxContext)
	53: FreezeRef
	54: Call tx_context::sender(&TxContext): address
	55: MoveLoc[1](Arg1: u64)
	56: Call add_addresses_minted(&mut TallyRegistry, address, u64)
	57: Ret
}

admin_mint(Arg0: &mut TallyRegistry, Arg1: u64, Arg2: &TransferPolicy<Tally>, Arg3: &mut Kiosk, Arg4: &KioskOwnerCap, Arg5: &mut TxContext) {
L6:	loc0: u64
L7:	loc1: Tally
B0:
	0: CopyLoc[0](Arg0: &mut TallyRegistry)
	1: ImmBorrowField[15](TallyRegistry.minted: u64)
	2: ReadRef
	3: CopyLoc[1](Arg1: u64)
	4: Add
	5: CopyLoc[0](Arg0: &mut TallyRegistry)
	6: ImmBorrowField[16](TallyRegistry.collection_size: u64)
	7: ReadRef
	8: Le
	9: BrFalse(11)
B1:
	10: Branch(23)
B2:
	11: MoveLoc[2](Arg2: &TransferPolicy<Tally>)
	12: Pop
	13: MoveLoc[0](Arg0: &mut TallyRegistry)
	14: Pop
	15: MoveLoc[4](Arg4: &KioskOwnerCap)
	16: Pop
	17: MoveLoc[3](Arg3: &mut Kiosk)
	18: Pop
	19: MoveLoc[5](Arg5: &mut TxContext)
	20: Pop
	21: LdU64(9223375150706327557)
	22: Abort
B3:
	23: LdU64(0)
	24: StLoc[6](loc0: u64)
B4:
	25: CopyLoc[6](loc0: u64)
	26: CopyLoc[1](Arg1: u64)
	27: Lt
	28: BrFalse(59)
B5:
	29: CopyLoc[5](Arg5: &mut TxContext)
	30: Call object::new(&mut TxContext): UID
	31: CopyLoc[0](Arg0: &mut TallyRegistry)
	32: ImmBorrowField[15](TallyRegistry.minted: u64)
	33: ReadRef
	34: LdConst[12](vector<u8>: "For..)
	35: Call string::utf8(vector<u8>): String
	36: LdConst[13](vector<u8>: "htt..)
	37: Call url::new_unsafe_from_bytes(vector<u8>): Url
	38: Call vec_map::empty<String, String>(): VecMap<String, String>
	39: Pack[1](Tally)
	40: StLoc[7](loc1: Tally)
	41: CopyLoc[0](Arg0: &mut TallyRegistry)
	42: ImmBorrowField[15](TallyRegistry.minted: u64)
	43: ReadRef
	44: LdU64(1)
	45: Add
	46: CopyLoc[0](Arg0: &mut TallyRegistry)
	47: MutBorrowField[15](TallyRegistry.minted: u64)
	48: WriteRef
	49: CopyLoc[3](Arg3: &mut Kiosk)
	50: CopyLoc[4](Arg4: &KioskOwnerCap)
	51: CopyLoc[2](Arg2: &TransferPolicy<Tally>)
	52: MoveLoc[7](loc1: Tally)
	53: Call kiosk::lock<Tally>(&mut Kiosk, &KioskOwnerCap, &TransferPolicy<Tally>, Tally)
	54: MoveLoc[6](loc0: u64)
	55: LdU64(1)
	56: Add
	57: StLoc[6](loc0: u64)
	58: Branch(25)
B6:
	59: MoveLoc[2](Arg2: &TransferPolicy<Tally>)
	60: Pop
	61: MoveLoc[4](Arg4: &KioskOwnerCap)
	62: Pop
	63: MoveLoc[3](Arg3: &mut Kiosk)
	64: Pop
	65: MoveLoc[0](Arg0: &mut TallyRegistry)
	66: MoveLoc[5](Arg5: &mut TxContext)
	67: FreezeRef
	68: Call tx_context::sender(&TxContext): address
	69: MoveLoc[1](Arg1: u64)
	70: Call add_addresses_minted(&mut TallyRegistry, address, u64)
	71: Ret
}

check_can_public_mint(Arg0: &TallyRegistry, Arg1: u64, Arg2: address, Arg3: &EarlyAccess) {
L4:	loc0: EarlyAccess
L5:	loc1: &EarlyAccess
L6:	loc2: bool
B0:
	0: MoveLoc[3](Arg3: &EarlyAccess)
	1: StLoc[5](loc1: &EarlyAccess)
	2: PackVariant(VariantHandleIndex(1))
	3: StLoc[4](loc0: EarlyAccess)
	4: MoveLoc[5](loc1: &EarlyAccess)
	5: ImmBorrowLoc[4](loc0: EarlyAccess)
	6: Neq
	7: BrFalse(17)
B1:
	8: CopyLoc[0](Arg0: &TallyRegistry)
	9: ImmBorrowField[0](TallyRegistry.can_public_mint: bool)
	10: ReadRef
	11: BrFalse(13)
B2:
	12: Branch(17)
B3:
	13: MoveLoc[0](Arg0: &TallyRegistry)
	14: Pop
	15: LdU64(9223375283850182659)
	16: Abort
B4:
	17: CopyLoc[0](Arg0: &TallyRegistry)
	18: ImmBorrowField[15](TallyRegistry.minted: u64)
	19: ReadRef
	20: CopyLoc[1](Arg1: u64)
	21: Add
	22: CopyLoc[0](Arg0: &TallyRegistry)
	23: ImmBorrowField[16](TallyRegistry.collection_size: u64)
	24: ReadRef
	25: Le
	26: BrFalse(28)
B5:
	27: Branch(32)
B6:
	28: MoveLoc[0](Arg0: &TallyRegistry)
	29: Pop
	30: LdU64(9223375301030182917)
	31: Abort
B7:
	32: CopyLoc[1](Arg1: u64)
	33: LdU64(0)
	34: Gt
	35: BrFalse(41)
B8:
	36: CopyLoc[1](Arg1: u64)
	37: LdConst[17](u64: 2)
	38: Le
	39: StLoc[6](loc2: bool)
	40: Branch(43)
B9:
	41: LdFalse
	42: StLoc[6](loc2: bool)
B10:
	43: MoveLoc[6](loc2: bool)
	44: BrFalse(46)
B11:
	45: Branch(50)
B12:
	46: MoveLoc[0](Arg0: &TallyRegistry)
	47: Pop
	48: LdU64(9223375313915215879)
	49: Abort
B13:
	50: MoveLoc[0](Arg0: &TallyRegistry)
	51: MoveLoc[2](Arg2: address)
	52: MoveLoc[1](Arg1: u64)
	53: Call check_max_nfts_per_address(&TallyRegistry, address, u64)
	54: Ret
}

add_addresses_minted(Arg0: &mut TallyRegistry, Arg1: address, Arg2: u64) {
L3:	loc0: &mut u64
B0:
	0: CopyLoc[0](Arg0: &mut TallyRegistry)
	1: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	2: CopyLoc[1](Arg1: address)
	3: Call table::contains<address, u64>(&Table<address, u64>, address): bool
	4: BrFalse(17)
B1:
	5: MoveLoc[0](Arg0: &mut TallyRegistry)
	6: MutBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	7: MoveLoc[1](Arg1: address)
	8: Call table::borrow_mut<address, u64>(&mut Table<address, u64>, address): &mut u64
	9: StLoc[3](loc0: &mut u64)
	10: CopyLoc[3](loc0: &mut u64)
	11: ReadRef
	12: MoveLoc[2](Arg2: u64)
	13: Add
	14: MoveLoc[3](loc0: &mut u64)
	15: WriteRef
	16: Branch(22)
B2:
	17: MoveLoc[0](Arg0: &mut TallyRegistry)
	18: MutBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	19: MoveLoc[1](Arg1: address)
	20: MoveLoc[2](Arg2: u64)
	21: Call table::add<address, u64>(&mut Table<address, u64>, address, u64)
B3:
	22: Ret
}

check_max_nfts_per_address(Arg0: &TallyRegistry, Arg1: address, Arg2: u64) {
B0:
	0: CopyLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	2: CopyLoc[1](Arg1: address)
	3: Call table::contains<address, u64>(&Table<address, u64>, address): bool
	4: BrFalse(20)
B1:
	5: CopyLoc[0](Arg0: &TallyRegistry)
	6: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	7: MoveLoc[1](Arg1: address)
	8: Call table::borrow<address, u64>(&Table<address, u64>, address): &u64
	9: ReadRef
	10: MoveLoc[2](Arg2: u64)
	11: Add
	12: MoveLoc[0](Arg0: &TallyRegistry)
	13: ImmBorrowField[18](TallyRegistry.max_nfts_per_address: u64)
	14: ReadRef
	15: Le
	16: BrFalse(18)
B2:
	17: Branch(22)
B3:
	18: LdU64(9223375404109529095)
	19: Abort
B4:
	20: MoveLoc[0](Arg0: &TallyRegistry)
	21: Pop
B5:
	22: Ret
}

has_mint_left(Arg0: &TallyRegistry, Arg1: address): bool {
L2:	loc0: bool
B0:
	0: CopyLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	2: CopyLoc[1](Arg1: address)
	3: Call table::contains<address, u64>(&Table<address, u64>, address): bool
	4: BrFalse(16)
B1:
	5: CopyLoc[0](Arg0: &TallyRegistry)
	6: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	7: MoveLoc[1](Arg1: address)
	8: Call table::borrow<address, u64>(&Table<address, u64>, address): &u64
	9: ReadRef
	10: MoveLoc[0](Arg0: &TallyRegistry)
	11: ImmBorrowField[18](TallyRegistry.max_nfts_per_address: u64)
	12: ReadRef
	13: Lt
	14: StLoc[2](loc0: bool)
	15: Branch(20)
B2:
	16: MoveLoc[0](Arg0: &TallyRegistry)
	17: Pop
	18: LdTrue
	19: StLoc[2](loc0: bool)
B3:
	20: MoveLoc[2](loc0: bool)
	21: Ret
}

public number(Arg0: &Tally): &u64 {
B0:
	0: MoveLoc[0](Arg0: &Tally)
	1: ImmBorrowField[12](Tally.number: u64)
	2: Ret
}

public description(Arg0: &Tally): &String {
B0:
	0: MoveLoc[0](Arg0: &Tally)
	1: ImmBorrowField[19](Tally.description: String)
	2: Ret
}

public url(Arg0: &Tally): &Url {
B0:
	0: MoveLoc[0](Arg0: &Tally)
	1: ImmBorrowField[14](Tally.url: Url)
	2: Ret
}

public attributes(Arg0: &Tally): &VecMap<String, String> {
B0:
	0: MoveLoc[0](Arg0: &Tally)
	1: ImmBorrowField[13](Tally.attributes: VecMap<String, String>)
	2: Ret
}

public balance(Arg0: &TallyRegistry): &Balance<SUI> {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[4](TallyRegistry.balance: Balance<SUI>)
	2: Ret
}

public minted(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[15](TallyRegistry.minted: u64)
	2: Ret
}

public collection_size(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[16](TallyRegistry.collection_size: u64)
	2: Ret
}

public can_public_mint(Arg0: &TallyRegistry): &bool {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[0](TallyRegistry.can_public_mint: bool)
	2: Ret
}

public max_nfts_per_address(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[18](TallyRegistry.max_nfts_per_address: u64)
	2: Ret
}

public addresses_minted(Arg0: &TallyRegistry): &Table<address, u64> {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[17](TallyRegistry.addresses_minted: Table<address, u64>)
	2: Ret
}

public public_mint_price(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[3](TallyRegistry.public_mint_price: u64)
	2: Ret
}

public early_mints(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[2](TallyRegistry.early_mints: u64)
	2: Ret
}

public early_mints_used(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[6](TallyRegistry.early_mints_used: u64)
	2: Ret
}

public free_mints(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[1](TallyRegistry.free_mints: u64)
	2: Ret
}

public free_mints_used(Arg0: &TallyRegistry): &u64 {
B0:
	0: MoveLoc[0](Arg0: &TallyRegistry)
	1: ImmBorrowField[7](TallyRegistry.free_mints_used: u64)
	2: Ret
}

Constants [
	0 => vector<u8>: "EInsufficientBalance" // interpreted as UTF8 string
	1 => vector<u8>: "Sender does not have enough balance to mint." // interpreted as UTF8 string
	2 => vector<u8>: "ENotStarted" // interpreted as UTF8 string
	3 => vector<u8>: "Minting or Revealing has not started." // interpreted as UTF8 string
	4 => vector<u8>: "EMintedOut" // interpreted as UTF8 string
	5 => vector<u8>: "All NFTs are minted out." // interpreted as UTF8 string
	6 => vector<u8>: "EAmountLimit" // interpreted as UTF8 string
	7 => vector<u8>: "NFT mint amount is not between 0 and MINTS_PER_TICKET, or address has reached mint limit." // interpreted as UTF8 string
	8 => vector<u8>: "EAlreadyRevealed" // interpreted as UTF8 string
	9 => vector<u8>: "NFT has already been revealed." // interpreted as UTF8 string
	10 => vector<u8>: "EAlreadyPublished" // interpreted as UTF8 string
	11 => vector<u8>: "Attributes or URLs have already been added to the shared Attributes object." // interpreted as UTF8 string
	12 => vector<u8>: "Forged in the heart of the Talus Kingdom, Tally NFTs grant their bearers the mantle of guardians, shaping the fate of AI agents on Sui and guiding its next great evolution" // interpreted as UTF8 string
	13 => vector<u8>: "https://tallys.talus.network/unminted.png" // interpreted as UTF8 string
	14 => vector<u8>: "Talus Labs" // interpreted as UTF8 string
	15 => vector<u8>: "https://tallys.talus.network" // interpreted as UTF8 string
	16 => u64: 5555
	17 => u64: 2
	18 => u64: 33000000000
	19 => u64: 5000000000
	20 => u64: 1
	21 => u16: 100
	22 => vector<u8>: "name" // interpreted as UTF8 string
	23 => vector<u8>: "description" // interpreted as UTF8 string
	24 => vector<u8>: "image_url" // interpreted as UTF8 string
	25 => vector<u8>: "attributes" // interpreted as UTF8 string
	26 => vector<u8>: "project_url" // interpreted as UTF8 string
	27 => vector<u8>: "creator" // interpreted as UTF8 string
	28 => vector<u8>: "Tally #{number}" // interpreted as UTF8 string
	29 => vector<u8>: "{description}" // interpreted as UTF8 string
	30 => vector<u8>: "{url}" // interpreted as UTF8 string
	31 => vector<u8>: "{attributes}" // interpreted as UTF8 string
	32 => vector<u8>: "Tally Mint Early Ticket" // interpreted as UTF8 string
	33 => vector<u8>: "This ticket gives you early access to Tally NFTs" // interpreted as UTF8 string
	34 => vector<u8>: "Tally Mint Free Ticket" // interpreted as UTF8 string
	35 => vector<u8>: "This ticket gives you free early access to Tally NFTs." // interpreted as UTF8 string
	36 => vector<u8>: "Tally NFT Registry" // interpreted as UTF8 string
	37 => vector<u8>: "Tally Attributes Registry" // interpreted as UTF8 string
	38 => vector<u8>: "no_config" // interpreted as UTF8 string
]
}
