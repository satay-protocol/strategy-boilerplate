module lending::lending {
    use aptos_framework::coin::Coin;
    use aptos_framework::object::Object;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Market has key {}

    public fun supply<CoinType>(account: &signer, market: Object<Market>, asset: Coin<CoinType>) {
        abort 0
    }

    public fun withdraw<CoinType>(account: &signer, market: Object<Market>, shares: u64): Coin<CoinType> {
        abort 0
    }

    public fun account_withdrawable_coins(account: address, market: Object<Market>): u64 {
        abort 0
    }
}
