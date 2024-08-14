module example_strategy::example_strategy {

    use std::signer;
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::fungible_asset::{Self, FungibleAsset, FungibleStore, Metadata};
    use aptos_framework::object;
    use aptos_framework::object::Object;
    use aptos_framework::primary_fungible_store;

    use satay::strategy::{Self, BaseStrategy};
    use satay::vault::Vault;

    struct StrategyWitness has drop {}

    struct StrategyCapability has key {
        strategy_cap: SignerCapability,
    }

    struct ExampleStrategy has key {
        vault: Object<Vault>,
        base_strategy: Object<BaseStrategy>,
    }

    const SEED_STRATEGY: vector<u8> = b"example_strategy";

    // initialize our strategy with the vault and the base asset
    public entry fun initialize(
        manager: &signer,
        vault: Object<Vault>,
        asset: Object<Metadata>
    ) {
        // Ensure this function is only called once
        assert!(!exists<ExampleStrategy>(signer::address_of(manager)), 0);

        // Create resource account for the strategy
        let (strategy_signer, strategy_cap) = account::create_resource_account(manager, SEED_STRATEGY);
        let base_strategy = strategy::create<StrategyWitness>(asset, StrategyWitness {});

        let cap = StrategyCapability { strategy_cap };
        let example_strategy = ExampleStrategy { vault, base_strategy };

        move_to(&strategy_signer, cap);
        move_to(&strategy_signer, example_strategy);
    }

    // deposit the base asset into the vault, and then issue the shares to the signer.
    public entry fun deposit(
        account: &signer,
        amount: u64,
        strategy_address: address
    ) acquires ExampleStrategy {
        let strategy = borrow_global<ExampleStrategy>(strategy_address);
        let account_address = signer::address_of(account);
        let user_store = primary_fungible_store::ensure_primary_store_exists(
            account_address,
            strategy::base_metadata(strategy.base_strategy)
        );

        let base_asset = deposit_(account, user_store, amount, strategy_address);
        primary_fungible_store::deposit(account_address, base_asset);
    }

    public fun deposit_(
        account: &signer,
        store: Object<FungibleStore>,
        amount: u64,
        strategy_address: address
    ): FungibleAsset acquires ExampleStrategy {
        let strategy = borrow_global<ExampleStrategy>(strategy_address);

        let base_asset = fungible_asset::withdraw(account, store, amount);
        let shares_asset = strategy::issue(strategy.base_strategy, &base_asset, &StrategyWitness {});

        // Implement the logic for interacting with the yield source
        // Example: deploy base_asset into a lending pool, stake it, etc.
        deploy_to_yield_source(base_asset);

        shares_asset
    }

    public fun withdraw(
        account: &signer,
        amount: u64,
        strategy_address: address
    ) acquires ExampleStrategy {
        let strategy = borrow_global<ExampleStrategy>(strategy_address);
        let account_address = signer::address_of(account);
        let store = primary_fungible_store::ensure_primary_store_exists(
            account_address,
            strategy::shares_metadata(strategy.base_strategy)
        );

        let asset = withdraw_internal(account, store, amount, strategy_address);
        fungible_asset::deposit(store, asset);
    }

    fun withdraw_internal(
        account: &signer,
        store: Object<FungibleStore>,
        amount: u64,
        strategy_address: address
    ): FungibleAsset acquires ExampleStrategy {
        let strategy = borrow_global<ExampleStrategy>(strategy_address);
        assert!(
            fungible_asset::store_metadata(store) == strategy::shares_metadata(strategy.base_strategy),
            0
        );

        let shares_asset = fungible_asset::withdraw(account, store, amount);
        let withdraw_amount = strategy::redeem(strategy.base_strategy, shares_asset, &StrategyWitness {});

        // Implement logic to check and withdraw from the yield source
        // If sufficient funds are in the strategy store, withdraw directly
        // Otherwise, handle withdrawals from yield sources

        if (!has_sufficient_funds(strategy, withdraw_amount)) {
            // Withdraw from the yield source
            return withdraw_from_yield_source(withdraw_amount, strategy);
        };

        //  no yield source or not enough funds, return zero
        return fungible_asset::zero(strategy::shares_metadata(strategy.base_strategy))
    }

    public fun vault(strategy: Object<ExampleStrategy>): Object<Vault> acquires ExampleStrategy {
        let strategy = borrow_global<ExampleStrategy>(object::object_address(&strategy));
        strategy.vault
    }

    public fun name(): vector<u8> {
        b"Example Strategy"
    }

    public fun version(): vector<u8> {
        b"0.0.2"
    }

    fun deploy_to_yield_source(asset: FungibleAsset) {
        // Implement the logic to deploy the asset into a yield-generating source
        abort 0
    }

    fun has_sufficient_funds(_strategy: &ExampleStrategy, _amount: u64): bool {
        // Implement logic to check if the strategy has sufficient funds to cover the withdrawal
        false
    }

    fun withdraw_from_yield_source(_amount: u64, strategy: &ExampleStrategy): FungibleAsset {
        // Implement logic to withdraw assets from the yield source
        fungible_asset::zero(strategy::shares_metadata(strategy.base_strategy))
    }
}
