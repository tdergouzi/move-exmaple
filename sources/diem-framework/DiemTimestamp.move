module DiemAddr::DiemTimestamp {
    use Std::Errors;
    use DiemAddr::CoreAddresses;

    struct CurrentTimeMicroseconds has key {
        microsecond: u64
    }

    /// Conversion factor between seconds and microseconds
    const MICRO_CONVERSION_FACTOR: u64 = 1000000;

    /// The blockchain is not in the genesis state anymore
    const ENOT_GENESIS: u64 = 0;
    /// The blockchain is not in an operating state yet
    const ENOT_OPERATING: u64 = 1;
    /// An invalid timestamp was provided
    const ETIMESTAMP: u64 = 2;

    public fun set_time_has_started(dr_account: &signer) {
        assert_genesis();
        CoreAddresses::assert_diem_root(dr_account);
        let timer = CurrentTimeMicroseconds{microsecond: 0};
        move_to(dr_account, timer);
    }

    public fun update_global_time(account: &signer, proposer: address, timestamp:u64) acquires CurrentTimeMicroseconds {
        assert_operating();
        CoreAddresses::assert_vm(account);

        let global_timer = borrow_global_mut<CurrentTimeMicroseconds>(CoreAddresses::DIEM_ROOT_ADDRESS());
        let now = global_timer.microsecond;
        if (proposer == CoreAddresses::VM_RESERVED_ADDRESS()) {
            assert!(now == timestamp, Errors::invalid_argument(ETIMESTAMP))
        } else {
            assert!(now < timestamp, Errors::invalid_argument(ETIMESTAMP))
        };
        global_timer.microsecond = timestamp;
    }

    public fun now_microseconds(): u64 acquires CurrentTimeMicroseconds {
        assert_operating();
        borrow_global<CurrentTimeMicroseconds>(CoreAddresses::DIEM_ROOT_ADDRESS()).microsecond
    }

    public fun now_seconds(): u64 acquires CurrentTimeMicroseconds {
        now_microseconds() / MICRO_CONVERSION_FACTOR
    }

    public fun is_genesis(): bool {
        !exists<CurrentTimeMicroseconds>(CoreAddresses::DIEM_ROOT_ADDRESS())
    }

    /// Assert genesis state.
    public fun assert_genesis() {
        assert!(is_genesis(), Errors::invalid_state(ENOT_GENESIS));
    }
    spec assert_genesis {
        pragma opaque = true;

    }
    spec schema AbortsIfNotGenesis {
        aborts_if !is_genesis() with Errors::INVALID_STATE;
    }

    public fun is_operating(): bool {
        exists<CurrentTimeMicroseconds>(CoreAddresses::DIEM_ROOT_ADDRESS())
    }

    /// Assert operating state.
    public fun assert_operating() {
        assert!(is_operating(), Errors::invalid_state(ENOT_OPERATING))
    }
    spec assert_operating {
        pragma opaque = true;
        include AbortsIfNotOperating;
    }
    spec schema AbortsIfNotOperating {
        aborts_if !is_operating() with Errors::INVALID_STATE;
    }

}