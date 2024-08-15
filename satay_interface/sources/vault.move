module satay::vault {
    use std::option::Option;
    use aptos_std::simple_map::SimpleMap;
    use aptos_framework::fungible_asset::{FungibleAsset, FungibleStore, Metadata};
    use aptos_framework::object::{Self, ConstructorRef, ExtendRef, Object, ObjectGroup};

    use satay::strategy::{BaseStrategy, StrategyState};

    #[resource_group_member(group = ObjectGroup)]
    struct Vault has key {
        /// The total amount of base asset the vault has deposited into strategies.
        total_debt: u64,
        /// This indicates if the vault is active or not.
        /// An inactive vault does not accept deposits but allows withdrawals.
        is_paused: bool,
        /// A fee that the protocol charges. If not set, the default protocol fee is used.
        protocol_fee: Option<u64>,
        /// The maximum amount of the base asset that can be deposited into the vault.
        deposit_limit: Option<u64>,
        /// The base asset (asset to be deposited) of the vault.
        base_metadata: Object<Metadata>,
        /// The shares asset (asset to be issued) of the vault.
        shares_metadata: Object<Metadata>,
        /// The addresses of the strategies that the vault uses.
        strategies: SimpleMap<address, StrategyState>,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct VaultController has key {
        manager: address,
        extend_ref: ExtendRef,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct VaultRegistry has key {
        vaults: vector<address>
    }

    struct WithdrawalRequest {
        to_withdraw: u64,
        vault: Object<Vault>,
        // to_burn: FungibleAsset,
        store: Object<FungibleStore>,
        strategies: SimpleMap<address, StrategyState>,
    }

    // ========== Events =========

    #[event]
    struct VaultCreated has store, drop {
        vault: address,
    }

    #[event]
    struct VaultDeposit has store, drop {
        amount: u64,
        vault: address
    }

    #[event]
    struct VaultPaused has store, drop {
        vault: address
    }

    #[event]
    struct VaultUnpaused has store, drop {
        vault: address
    }

    // ========== Constants =========

    const DEBT_RATIO_MAX: u64 = 10_000;
    const PROTOCOL_FEE_MAX: u64 = 5000;

    const U64_MAX: u64 = 18446744073709551615;

    // ========== Errors =========

    const ENOT_GOVERNANCE: u64 = 0;
    const EDEPOSIT_LIMIT_TOO_LOW: u64 = 0;
    const EPROTOCOL_FEE_TOO_HIGH: u64 = 1;
    const EVAULT_BASE_ASSET_MISMATCH: u64 = 2;
    const EINSUFFICIENT_BALANCE: u64 = 3;
    const EVAULT_NOT_PAUSED: u64 = 4;
    const EVAULT_ALREADY_PAUSED: u64 = 5;
    const ECANNOT_EXCEED_DEPOSIT_LIMIT: u64 = 5;
    const ESTRATEGY_ALREADY_ADDED: u64 = 6;
    const ESTRATEGY_NOT_EXISTS: u64 = 7;
    const EVAULT_ASSET_NOT_INITIALIZED: u64 = 8;
    const EVAULT_SHARES_ASSET_MISMATCH: u64 = 9;
    const EDEBT_RATIO_TOO_HIGH: u64 = 10;
    const ESTRATEGY_STATE_MISMATCH: u64 = 11;
    const ESTRATEGY_STATE_NOT_FOUND: u64 = 12;
    const EVAULT_NOT_ACTIVE: u64 = 14;
    const ESTRATEGY_BASE_METADATA_MISMATCH: u64 = 15;
    const ESTRATEGY_HAS_DEBT: u64 = 16;

    // ========== Public functions =========

    public(friend) fun create(
        account: &signer,
        deposit_limit: Option<u64>,
        protocol_fee: Option<u64>,
        base_metadata: Object<Metadata>
    ): Object<Vault> {
       abort 0
    }

    public fun deposit(
        account: &signer,
        vault: Object<Vault>,
        store: Object<FungibleStore>,
        amount: u64
    ): FungibleAsset  {
      abort 0
    }

    public fun initialize_withdrawal(
        account: &signer,
        vault: Object<Vault>,
        store: Object<FungibleStore>,
        amount: u64
    ): WithdrawalRequest  {
        abort 0
    }

    public fun withdraw(withdrawal: &mut WithdrawalRequest): FungibleAsset {
        abort 0
    }

    public fun add_strategy(
        account: &signer,
        vault: Object<Vault>,
        strategy: Object<BaseStrategy>,
    )  {
        abort 0
    }

    public fun remove_strategy(
        account: &signer,
        vault: Object<Vault>,
        strategy: Object<BaseStrategy>,
        force: bool
    )  {
     abort 0
    }


    #[view]
    public fun amount_to_shares(vault: Object<Vault>, amount: u64): u64  {
        abort 0
    }

    #[view]
    public fun shares_to_amount(vault: Object<Vault>, shares: u64): u64  {
        abort 0
    }

    #[view]
    public fun total_assets(vault: Object<Vault>): u64  {
        abort 0
    }

    #[view]
    public fun total_available(vault: Object<Vault>): u64  {
        abort 0
    }

    #[view]
    public fun total_shares(vault: Object<Vault>): u64  {
        abort 0
    }

    #[view]
    public fun base_metadata(vault: Object<Vault>): Object<Metadata>  {
        abort 0
    }

    #[view]
    public fun shares_metadata(vault: Object<Vault>): Object<Metadata>  {
        abort 0
    }
}

