module echelon_usdt::echelon_usdt {

    use std::signer;
    use aptos_std::math64;
    use aptos_framework::coin;
    use aptos_framework::fungible_asset::{Self, FungibleAsset, Metadata};
    use aptos_framework::object::{Self, ExtendRef, Object};
    use aptos_framework::primary_fungible_store;

    use lending::lending::{Self as echelon, Market};
    use satay::protocol;
    use satay::strategy::{Self, Strategy};
    use satay::vault::{Self, Vault, WithdrawalRequest};

    struct EchelonUSDT has drop {}

    #[resource_group_member(group = object::ObjectGroup)]
    struct EchelonUSDTStrategy has key {
        vault: Object<Vault>,
        market: Object<Market>,
        base_strategy: Object<Strategy>,
    }

    #[resource_group_member(group = object::ObjectGroup)]
    struct EchelonUSDTStrategyController has key {
        extend_ref: ExtendRef,
    }

    const SEED_STRATEGY: vector<u8> = b"0EchelonUSDTStrategy";

    const EINVALID_REDEEM_AMOUNT: u64 = 0;
    const EINVALID_ASSET_METADATA: u64 = 1;

    // Initialize the strategy with the vault and the base asset
    public entry fun initialize(
        manager: &signer,
        vault: Object<Vault>,
        asset: Object<Metadata>,
        market: Object<Market>
    ) {
        let constructor_ref = strategy::create_impl_object(SEED_STRATEGY);
        let transfer_ref = object::generate_transfer_ref(&constructor_ref);
        object::disable_ungated_transfer(&transfer_ref);

        assert!(vault::base_metadata(vault) == asset, EINVALID_ASSET_METADATA);

        let strategy_signer = object::generate_signer(&constructor_ref);
        let base_strategy = strategy::create<EchelonUSDT>(manager, asset, EchelonUSDT {});

        let strategy = EchelonUSDTStrategy { vault, market, base_strategy };
        let controller = EchelonUSDTStrategyController { extend_ref: object::generate_extend_ref(&constructor_ref) };

        move_to(&strategy_signer, controller);
        move_to(&strategy_signer, strategy);
    }

    public entry fun deposit<CoinType>(account: &signer, amount: u64) acquires EchelonUSDTStrategy {
        let strategy = borrow_self();
        let account_address = signer::address_of(account);
        let base_metadata = strategy::base_metadata(strategy.base_strategy);

        let asset = coin::withdraw<CoinType>(account, amount);
        let wrapped_asset = strategy::wrap_asset(strategy.base_strategy, asset, &EchelonUSDT {});
        assert!(fungible_asset::asset_metadata(&wrapped_asset) == base_metadata, EINVALID_ASSET_METADATA);

        let shares_asset = deposit_asset<CoinType>(wrapped_asset);
        primary_fungible_store::deposit(account_address, shares_asset);
    }

    public fun deposit_asset<CoinType>(base_asset: FungibleAsset): FungibleAsset acquires EchelonUSDTStrategy {
        let strategy = borrow_self();
        let shares_asset = strategy::issue(strategy.base_strategy, &base_asset, &EchelonUSDT {});
        primary_fungible_store::deposit(
            @0xa97226fc785cb0c2e2e1dd795e1edceddc1e5b349b3c12152c7979c030c679f7,
            base_asset
        );

        // let signer = strategy::get_strategy_signer(strategy.base_strategy, &EchelonUSDT {});
        //
        // let coin = strategy::unwrap_asset<EchelonUSDT, CoinType>(
        //     strategy.base_strategy,
        //     base_asset,
        //     &EchelonUSDT {}
        // );
        // echelon::supply(&signer, strategy.market, coin);

        shares_asset
    }

    public fun vault_withdrawal<CoinType>(request: &mut WithdrawalRequest): u64 acquires EchelonUSDTStrategy {
        let to_withdraw = vault::to_withdraw(request);
        if (to_withdraw == 0) return 0;

        let self = borrow_self();
        let witness = &EchelonUSDT {};
        let base_strategy = self.base_strategy;

        let total_asset = strategy::total_asset(base_strategy);
        let base_signer = &strategy::get_strategy_signer(base_strategy, witness);

        // Determine how much asset to withdraw, we can't withdraw more than the total asset
        let withdrawable = math64::min(to_withdraw, total_asset);
        if (withdrawable == 0) return 0;

        // convert the withdrawable amount into shares
        let shares_amount = strategy::amount_to_shares(base_strategy, withdrawable);
        let shares_asset = vault::withdraw_strategy_shares(base_signer, self.vault, shares_amount);
        let redeemable = strategy::redeem(self.base_strategy, shares_asset, &EchelonUSDT {});

        // Make sure the redeemed amount matches the withdrawable amount
        assert!(redeemable == withdrawable, EINVALID_REDEEM_AMOUNT);

        let redeemed_coin = echelon::withdraw<CoinType>(base_signer, self.market, redeemable);
        let redeemed_amount = coin::value(&redeemed_coin);

        let redeemed_asset = strategy::wrap_asset<EchelonUSDT, CoinType>(
            self.base_strategy,
            redeemed_coin,
            &EchelonUSDT {}
        );

        if (redeemed_amount > redeemable) {
            let profit = redeemed_amount - redeemable;

            let profit_asset = fungible_asset::extract(&mut redeemed_asset, profit);
            vault::deposit_strategy_shares(base_signer, self.vault, deposit_asset<CoinType>(profit_asset));
        };


        let final_amount = fungible_asset::amount(&redeemed_asset);
        vault::collect_withdrawal_asset(request, redeemed_asset);
        final_amount
    }

    public fun vault(): Object<Vault> acquires EchelonUSDTStrategy {
        let strategy = borrow_global<EchelonUSDTStrategy>(self_address());
        strategy.vault
    }

    // public fun self(): Object<EchelonUSDTStrategy> {
    //     let strategy_address = self_address();
    //
    //     assert!(object::object_exists<EchelonUSDTStrategy>(strategy_address), 0);
    //     object::address_to_object<EchelonUSDTStrategy>(strategy_address)
    // }

    inline fun borrow_self(): &EchelonUSDTStrategy acquires EchelonUSDTStrategy {
        let strategy_address = self_address();
        borrow_global<EchelonUSDTStrategy>(strategy_address)
    }

    inline fun borrow_controller<T>(): &EchelonUSDTStrategyController acquires EchelonUSDTStrategyController {
        let strategy_address = self_address();
        borrow_global<EchelonUSDTStrategyController>(strategy_address)
    }

    public fun name(): vector<u8> {
        b"EchelonUSDT Strategy"
    }

    public fun version(): vector<u8> {
        b"0.0.0"
    }

    fun self_address(): address {
        object::create_object_address(&protocol::get_address(), SEED_STRATEGY)
    }

    fun self_signer(): signer acquires EchelonUSDTStrategyController {
        object::generate_signer_for_extending(&borrow_controller<EchelonUSDTStrategyController>().extend_ref)
    }
}
