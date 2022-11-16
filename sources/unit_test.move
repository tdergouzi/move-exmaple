module example::UnitTest {
    struct MyCoin has key {value: u64}

    public fun make_sure_non_zero_coin(coin: MyCoin): MyCoin {
        assert!(coin.value > 0, 0);
        coin
    }

    public fun has_coin(addr: address): bool {
        exists<MyCoin>(addr)
    }

    # [test]
    fun make_sure_non_zero_coin_passes() {
        let coin = MyCoin{value: 1};
        let MyCoin{value: _} = make_sure_non_zero_coin(coin);
    }

    # [test]
    # [expected_failure]
    fun make_sure_non_zero_coin_fails() {
        let coin = MyCoin{value: 0};
        let MyCoin{value: _} = make_sure_non_zero_coin(coin);
    }

    # [test_only] // test only helper function
    fun publish_coin(account: &signer) {
        move_to(account, MyCoin{value: 1})
    }

    # [test(a = @0x1, b = @0x2)]
    fun test_has_coin(a: signer, b: signer) {
        publish_coin(&a);
        publish_coin(&b);
        assert!(has_coin(@0x1), 0);
        assert!(has_coin(@0x2), 1);
        assert!(!has_coin(@0x3), 2);
    }
}