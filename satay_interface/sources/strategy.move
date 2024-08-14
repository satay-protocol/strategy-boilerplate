module satay::strategy {
    use std::option;
    use std::string::utf8;
    use aptos_std::math64;
    use aptos_std::type_info;
    use aptos_std::type_info::TypeInfo;
    use aptos_framework::fungible_asset;
    use aptos_framework::fungible_asset::{FungibleAsset, FungibleStore, Metadata};
    use aptos_framework::object;
    use aptos_framework::object::{ConstructorRef, ExtendRef, Object, ObjectGroup};
    use aptos_framework::timestamp;


    #[resource_group_member(group = ObjectGroup)]
    struct BaseStrategy has key {
        total_asset: u64,
        /// Timestamp of the last profit collection.
        last_harvest: u64,
        /// Witness type for the strategy.
        witness_type: TypeInfo,
        /// The metadata of the base(deposit) asset.
        base_metadata: Object<Metadata>,
        /// The metadata of the shares asset.
        shares_metadata: Object<Metadata>,
    }

    #[resource_group_member(group = ObjectGroup)]
    struct BaseStrategyController has key {
        extend_ref: ExtendRef,
    }

    struct StrategyState has store {
        /// The debt ceiling of the strategy.
        debt_limit: u64,
        /// The current amount of debt of the strategy.
        current_debt: u64,
        /// The time when the strategy was last reported.
        last_report: u64,
    }

    const DEBT_RATIO_MAX: u64 = 10000;

    const ENOT_VAULT_MANAGER: u64 = 0;
    const ENOT_GOVERNANCE: u64 = 1;
    const EDEBT_RATIO_TOO_HIGH: u64 = 2;
    const ESTRATEGY_WITNESS_MISMATCH: u64 = 3;
    const EINVALID_AMOUNT: u64 = 4;
    const EINVALID_SHARES_AMOUNT: u64 = 5;
    const ESTRATEGY_BASE_ASSET_MISMATCH: u64 = 6;

    public fun create<T: drop>(base_asset: Object<Metadata>, _witness: T): Object<BaseStrategy> {
       abort 0
    }

    public fun issue<T>(
        strategy: Object<BaseStrategy>,
        asset: &FungibleAsset,
        _: &T
    ): FungibleAsset {
       abort 0
    }

    public fun redeem<T>(
        strategy: Object<BaseStrategy>,
        asset: FungibleAsset,
        _: &T
    ): u64 {
       abort 0
    }

    public(friend) fun set_current_debt(state: &mut StrategyState, current_debt: u64) {
        abort 0
    }

    public(friend) fun new_state(): StrategyState {
        abort 0
    }

    public(friend) fun destroy_state(state: StrategyState) {
       abort 0
    }

    public fun debt_limit(state: &StrategyState): u64 {
        abort 0
    }

    public fun current_debt(state: &StrategyState): u64 {
        abort 0
    }

    public fun last_report(state: &StrategyState): u64 {
        abort 0
    }

    public(friend) fun set_debt_limit(state: &mut StrategyState, debt_limit: u64) {
        abort 0
    }

    fun create_shares_asset(
        strategy_signer: &signer,
        base_asset: Object<Metadata>,
        witness_type: &TypeInfo
    ): Object<Metadata> {
        abort 0
    }

    fun create_internal(
        constructor_ref: &ConstructorRef,
        base_metadata: Object<Metadata>,
        shares_metadata: Object<Metadata>,
        witness_type: TypeInfo
    ): (BaseStrategy, BaseStrategyController) {
        abort 0
    }

    fun issue_internal(
        strategy: Object<BaseStrategy>,
        asset: &FungibleAsset
    ): FungibleAsset {
       abort 0
    }

    fun redeem_internal(
        strategy: Object<BaseStrategy>,
        asset: FungibleAsset
    ): u64 {
        abort 0
    }

    public fun base_metadata(strategy: Object<BaseStrategy>): Object<Metadata> {
        abort 0
    }

    fun is_valid_witness<T>(strategy: Object<BaseStrategy>): bool {
        abort 0
    }

    inline fun borrow_strategy(strategy: &Object<BaseStrategy>): &BaseStrategy {
        borrow_global<BaseStrategy>(object::object_address(strategy))
    }

    inline fun borrow_strategy_mut(strategy: &Object<BaseStrategy>): &mut BaseStrategy {
        borrow_global_mut<BaseStrategy>(object::object_address(strategy))
    }

    inline fun borrow_strategy_controller(strategy: &Object<BaseStrategy>): &BaseStrategyController {
        borrow_global<BaseStrategyController>(object::object_address(strategy))
    }

    public fun strategy_address(strategy: Object<BaseStrategy>): address {
        abort 0
    }

    #[view]
    public fun total_asset(vault: Object<BaseStrategy>): u64 {
        abort 0
    }

    #[view]
    public fun total_shares(vault: Object<BaseStrategy>): u64 {
        abort 0
    }

    #[view]
    public fun shares_metadata(strategy: Object<BaseStrategy>): Object<Metadata> {
        abort 0
    }

    public fun base_store(strategy: Object<BaseStrategy>): Object<FungibleStore> {
        abort 0
    }

    public fun shares_store(strategy: Object<BaseStrategy>): Object<FungibleStore> {
        abort 0
    }

    #[view]
    public fun amount_to_shares(strategy: Object<BaseStrategy>, amount: u64): u64 {
        abort 0
    }

    #[view]
    public fun shares_to_amount(strategy: Object<BaseStrategy>, shares: u64): u64 {
        abort 0
    }

    #[view]
    public fun witness_type(strategy: Object<BaseStrategy>): TypeInfo {
        abort 0
    }
}
