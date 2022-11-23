module DiemAddr::RegisteredCurrencies {
    use Std::Errors;
    use Std::Vector;
    use DiemAddr::DiemConfig;
    use DiemAddr::DiemTimestamp;
    use DiemAddr::Roles;

    struct RegisteredCurrencies has key, copy, drop, store {
        currency_codes: vector<u8>
    }

    const ECURRENCY_CODE_ALREADY_TAKEN: u64 = 0;

    public fun initialize(dr_account: &signer) {
        DiemTimestamp::assert_genesis();
        Roles::assert_diem_root(dr_account);
        DiemConfig::publish_new_config(dr_account, RegisteredCurrencies{currency_codes: Vector::empty()})
    }

    public fun add_currency_code(dr_account: &signer, currency_code: u8) {
        let config = DiemConfig::get<RegisteredCurrencies>();
        assert!(!Vector::contains(&config.currency_codes, &currency_code), Errors::invalid_argument(ECURRENCY_CODE_ALREADY_TAKEN));
        Vector::push_back(&mut config.currency_codes, currency_code);
        DiemConfig::set(dr_account, config)
    }
}