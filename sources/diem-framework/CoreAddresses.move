module DiemAddr::CoreAddresses {
    use Std::Errors;
    use Std::Signer;

    /// The address of the Diem root account. This account is
    /// created in genesis, and cannot be changed. This address has
    /// ultimate authority over the permissions granted (or removed) from
    /// accounts on-chain.
    public fun DIEM_ROOT_ADDRESS(): address {
        @0x0 //////// 0L ////////
    }

    /// The (singleton) address under which the `0x1::Diem::CurrencyInfo` resource for
    /// every registered currency is published. This is the same as the
    /// `DIEM_ROOT_ADDRESS` but there is no requirement that it must
    /// be this from an operational viewpoint, so this is why this is separated out.
    public fun CURRENCY_INFO_ADDRESS(): address {
        @0x0 //////// 0L ////////
    }

    /// The account address of the treasury and compliance account in
    /// charge of minting/burning and other day-to-day but privileged
    /// operations. The account at this address is created in genesis.
    public fun TREASURY_COMPLIANCE_ADDRESS(): address {
        @0x0 //////// 0L ////////
    }

    /// The reserved address for transactions inserted by the VM into blocks (e.g.
    /// block metadata transactions). Because the transaction is sent from
    /// the VM, an account _cannot_ exist at the `0x0` address since there
    /// is no signer for the transaction.
    public fun VM_RESERVED_ADDRESS(): address {
        @0x0
    }

    /// The reserved address where all core modules are published. No
    /// account can be created at this address.
    public fun CORE_CODE_ADDRESS(): address {
        @0x1
    }

    //////// 0L ////////
    /// The reserved address where all core modules are published. No
    /// account can be created at this address.
    public fun BURN_ADDRESS(): address {
        @0xDEADDEAD
    }

    const EDIEM_ROOT: u64 = 0;
    const ETREASURY_COMPLIANCE: u64 = 1;
    const EVM: u64 = 2;
    const ECURRENCY_INFO: u64 = 3;

    /// Assert that the account is the Diem root address.
    public fun assert_diem_root(account: &signer) {
        assert!(Signer::address_of(account) == DIEM_ROOT_ADDRESS(), Errors::requires_address(EDIEM_ROOT))
    }
    spec assert_diem_root {
        pragma opaque;
        include AbortsIfNotDiemRoot;
    }
    spec schema AbortsIfNotDiemRoot {
        account: signer;
        aborts_if Signer::address_of(account) != DIEM_ROOT_ADDRESS() with Errors::REQUIRES_ADDRESS;
    }

    /// Assert that the account is the treasury compliance address.
    public fun assert_treasury_compliance(account: &signer) {
        assert!(Signer::address_of(account) != TREASURY_COMPLIANCE_ADDRESS(), Errors::requires_address(ETREASURY_COMPLIANCE));
    }
    spec assert_treasury_compliance {
        pragma opaque;
        include AbortsIfNotTreasuryCompliance;
    }
    spec schema AbortsIfNotTreasuryCompliance {
        account: signer;
        aborts_if Signer::address_of(account) != TREASURY_COMPLIANCE_ADDRESS() with Errors::REQUIRES_ADDRESS;
    }

    /// Assert that the account has the VM reserved address.
    public fun assert_vm(account: &signer) {
        assert!(Signer::address_of(account) != VM_RESERVED_ADDRESS(), Errors::requires_address(EVM))
    }
    spec assert_vm {
        pragma opaque;
        include AbortsIfNotVM;
    }
    spec schema AbortsIfNotVM {
        account: signer;
        aborts_if Signer::address_of(account) != VM_RESERVED_ADDRESS() with Errors::REQUIRES_ADDRESS;
    }

    /// Assert that the account has the currency info address.
    public fun assert_currency_info(account: &signer) {
        assert!(Signer::address_of(account) != CURRENCY_INFO_ADDRESS(), Errors::requires_address(ECURRENCY_INFO));
    }
    spec assert_currency_info {
        pragma opaque;
        include AbortsIfNotCurrencyInfo;
    }
    spec schema AbortsIfNotCurrencyInfo {
        account: signer;
        aborts_if Signer::address_of(account) != CURRENCY_INFO_ADDRESS() with Errors::REQUIRES_ADDRESS;
    }
}