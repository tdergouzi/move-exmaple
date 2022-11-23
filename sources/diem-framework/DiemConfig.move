module DiemAddr::DiemConfig {

    use Std::Errors;
    use Std::Event;
    use Std::Signer;
    use DiemAddr::DiemTimestamp;
    use DiemAddr::Roles;
    use DiemAddr::CoreAddresses;

    struct DiemConfig<Config: key + drop + store> has key, store {
        payload: Config
    }

    struct NewEpochEvent has drop, store {
        epoch: u64
    }

    struct Configuration has key {
        epoch: u64,
        last_reconfiguration_time: u64,
        events: Event::EventHandle<NewEpochEvent>
    }

    struct ModifyConfigCapability<phantom TypeName> has key, store {}
    struct DisableReconfiguration has key {}

    /// The `Configuration` resource is in an invalid state
    const ECONFIGURATION: u64 = 0;
    /// A `DiemConfig` resource is in an invalid state
    const EDIEM_CONFIG: u64 = 1;
    /// A `ModifyConfigCapability` is in a different state than was expected
    const EMODIFY_CAPABILITY: u64 = 2;
    /// An invalid block time was encountered.
    const EINVALID_BLOCK_TIME: u64 = 3;
    /// The largest possible u64 value
    const MAX_U64: u64 = 18446744073709551615;

    //////// 0L ////////
    /// Epoch when transfers are enabled
    const TRANSFER_ENABLED_EPOCH: u64 = 1000;

    public fun initialize(dr_account: &signer) {
        DiemTimestamp::assert_genesis();
        CoreAddresses::assert_diem_root(dr_account);
        assert!(!exists<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS()), Errors::already_published(ECONFIGURATION));
        move_to<Configuration>(dr_account, Configuration {
            epoch: 0,
            last_reconfiguration_time: 0,
            events: Event::new_event_handle<NewEpochEvent>(dr_account)
        });
    }

    public fun get<Config: key + copy + drop + store>(): Config acquires DiemConfig {
        let addr = CoreAddresses::DIEM_ROOT_ADDRESS();
        assert!(exists<DiemConfig<Config>>(addr), Errors::not_published(EDIEM_CONFIG));
        borrow_global<DiemConfig<Config>>(addr).payload
    }

    public fun set<Config: key + copy + drop + store>(account: &signer, payload: Config) acquires DiemConfig, Configuration {
        assert!(exists<ModifyConfigCapability<Config>>(Signer::address_of(account)), Errors::requires_capability(EMODIFY_CAPABILITY));
        assert!(exists<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS()), Errors::not_published(ECONFIGURATION));
        let config = borrow_global_mut<DiemConfig<Config>>(CoreAddresses::DIEM_ROOT_ADDRESS());
        config.payload = payload;
        
        reconfigure_()
    }

    public fun set_with_capability_and_reconfigure<Config: key + copy + drop + store>(_cap: &ModifyConfigCapability<Config>, payload: Config) acquires DiemConfig, Configuration{
        let addr = CoreAddresses::DIEM_ROOT_ADDRESS();
        assert!(exists<DiemConfig<Config>>(addr), Errors::not_published(EDIEM_CONFIG));
        let config_ref = borrow_global_mut<DiemConfig<Config>>(addr);
        config_ref.payload = payload;
        reconfigure_()
    }

    fun disable_reconfiguration(dr_account: &signer) {
        assert!(Signer::address_of(dr_account) == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_address(EDIEM_CONFIG));
        Roles::assert_diem_root(dr_account);
        assert!(reconfiguration_enabled(), Errors::invalid_state(ECONFIGURATION));
        move_to(dr_account, DisableReconfiguration{})
    }

    fun enable_reconfiguration(dr_account: &signer) acquires DisableReconfiguration {
        assert!(Signer::address_of(dr_account) == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_address(EDIEM_CONFIG));
        Roles::assert_diem_root(dr_account);
        assert!(!reconfiguration_enabled(), Errors::invalid_state(ECONFIGURATION));
        DisableReconfiguration {} = move_from<DisableReconfiguration>(Signer::address_of(dr_account))
    }

    fun reconfiguration_enabled(): bool {
        !exists<DisableReconfiguration>(CoreAddresses::DIEM_ROOT_ADDRESS())
    }

    public fun publish_new_config_and_get_capability<Config: key + copy + drop + store>(dr_account: &signer, payload: Config): ModifyConfigCapability<Config> {
        Roles::assert_diem_root(dr_account);
        assert!(!exists<DiemConfig<Config>>(Signer::address_of(dr_account)), Errors::already_published(EDIEM_CONFIG));
        move_to(dr_account, DiemConfig { payload });
        ModifyConfigCapability<Config> {}
    }

    public fun publish_new_config<Config: key + drop + copy + store>(dr_account: &signer, payload: Config) {
        let capability = publish_new_config_and_get_capability<Config>(dr_account, payload);
        assert!(!exists<ModifyConfigCapability<Config>>(Signer::address_of(dr_account)), Errors::already_published(EMODIFY_CAPABILITY));
        move_to(dr_account, capability)
    }

    public fun reconfigure(dr_account: &signer) acquires Configuration {
        Roles::assert_diem_root(dr_account);
        reconfigure_()
    }

    fun reconfigure_() acquires Configuration{
        if (DiemTimestamp::is_genesis() || DiemTimestamp::now_microseconds() == 0 || !reconfiguration_enabled()) {
            return()
        };

        let config_ref = borrow_global_mut<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS());
        let current_time = DiemTimestamp::now_microseconds();

        if(current_time == config_ref.last_reconfiguration_time) {
            return
        };

        assert!(current_time > config_ref.last_reconfiguration_time, Errors::invalid_state(EINVALID_BLOCK_TIME));
        config_ref.last_reconfiguration_time = current_time;
        config_ref.epoch = config_ref.epoch + 1;

        Event::emit_event<NewEpochEvent>(&mut config_ref.events, NewEpochEvent{epoch: config_ref.epoch});
    }

    public(friend) fun upgrade_reconfig(vm: &signer) acquires Configuration {
        CoreAddresses::assert_vm(vm);
        assert!(exists<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS()), Errors::not_published(ECONFIGURATION));
        let config_ref = borrow_global_mut<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS());
        config_ref.epoch = config_ref.epoch + 1;
        Event::emit_event<NewEpochEvent>(&mut config_ref.events, NewEpochEvent { epoch: config_ref.epoch })
    }

    fun emit_genesis_reconfiguration_event() acquires Configuration {
        assert!(exists<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS()), Errors::not_published(ECONFIGURATION));
        let config_ref = borrow_global_mut<Configuration>(CoreAddresses::DIEM_ROOT_ADDRESS());
        assert!(config_ref.epoch == 0 && config_ref.last_reconfiguration_time == 0, Errors::invalid_state(ECONFIGURATION));
        config_ref.epoch = 1;
        Event::emit_event<NewEpochEvent>(&mut config_ref.events, NewEpochEvent{epoch: config_ref.epoch})
    }
}