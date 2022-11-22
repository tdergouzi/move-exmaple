module DiemAddr::Diem {
    use Std::Errors;
    use Std::Event::{Self, EventHandle};
    use Std::FixedPoint32::{Self, FixedPoint32};
    use Std::Signer;
    use Std::Role;
    use Std::Vector;
    use DiemAddr::CoreAddresses;
    use DiemAddr::RegisteredCurrencies;
    use DiemAddr::DiemTimestamp;

    struct Diem<phantom CoinType> has key, store {
        value: u64
    }

    struct MintCapability<phantom CoinType> has key, store {}
    struct BurnCapability<phantom CoinType> has key, store {}

    struct MintEvent has drop, store {
        /// Funds added to the system
        amount: u64,
        /// ASCII encoded symbol for the coin type (e.g., "GAS")
        currency_code: vector<u8>
    }

    struct BurnEvent has drop, store {
        /// Funds removed from the system
        amount: u64,
        /// ASCII encoded symbol for the coin type (e.g., "GAS")
        currency_code: vector<u8>,
        /// Address with the `PreburnQueue` resource that stored the now-burned funds
        preburn_address: address
    }

    struct PreburnEvent has drop, store {
        /// The amount of funds wait to be removed (burned) from the system
        amount: u64,
        /// ASCII encoded symbol for the coin type (e.g., "GAS")
        currency_code: vector<u8>,
        /// Address with the `PreburnQueue` resource that now holds the funds
        preburn_address: address
    }

    struct CancelBurnevent has drop, store {
        amount: u64,
        currency_code: vector<u8>,
        preburn_address: address
    }

    struct ToXDXExchangeRateUpdateEvent has drop, store {
        currency_code: vector<u8>,
        new_to_xdx_exchange_rate: u64
    }

    struct CurrencyInfo<phantom CoinType> has key {
        /// The total value for the currency represented by `CoinType`. Mutable.
        total_value: u64,
        preburn_value: u64,
        to_xdx_exchange_rate: FixedPoint32,
        is_synthetic: bool,
        scaling_factor: u64,
        fractional_part: u64,
        currency_code: vector<u8>,
        can_mint: bool,
        mint_events: EventHandle<MintEvent>,
        burn_events: EventHandle<BurnEvent>,
        preburn_events: EventHandle<PreburnEvent>,
        cancel_burn_events: EventHandle<CancelBurnevent>,
        exchange_rate_update_events: EventHandle<ToXDXExchangeRateUpdateEvent>
    }

    /// The maximum value for `CurrencyInfo.scaling_factor`
    const MAX_SCALING_FACTOR: u64 = 10000000000;

    /// Data structure invariant for CurrencyInfo. Asserts that `CurrencyInfo.scaling_factor`
    /// is always greater than 0 and not greater than `MAX_SCALING_FACTOR`
    spec CurrencyInfo {
        invariant 0 < scaling_factor && scaling_factor <= MAX_SCALING_FACTOR;
    }

    struct Preburn<phantom CoinType> has key, store {
        to_burn: Diem<CoinType>
    }

    struct PreburnWithMetadata<phantom CoinType> has store {
        preburn: Preburn<CoinType>,
        metadata: vector<u8>
    }

    struct PreburnQueue<phantom CoinType> has key {
        preburns: vector<PreburnWithMetadata<CoinType>>
    }

    spec PreburnQueue {
        invariant len(preburns) <= MAX_OUTSTANDING_PREBURNS;
        invariant forall i in 0..len(preburns): preburns[i].preburn.to_burn.value > 0;
    }

    /// Maximum u64 value.
    const MAX_U64: u64 = 18446744073709551615;
    /// Maximum u128 value.
    const MAX_U128: u128 = 340282366920938463463374607431768211455;

    /// A `BurnCapability` resource is in an unexpected state.
    const EBURN_CAPABILITY: u64 = 0;
    /// A property expected of a `CurrencyInfo` resource didn't hold
    const ECURRENCY_INFO: u64 = 1;
    /// A property expected of a `Preburn` resource didn't hold
    const EPREBURN: u64 = 2;
    /// The preburn slot is already occupied with coins to be burned.
    const EPREBURN_OCCUPIED: u64 = 3;
    /// A burn was attempted on `Preburn` resource that cointained no coins
    const EPREBURN_EMPTY: u64 = 4;
    /// Minting is not allowed for the specified currency
    const EMINTING_NOT_ALLOWED: u64 = 5;
    /// The currency specified is a synthetic (non-fiat) currency
    const EIS_SYNTHETIC_CURRENCY: u64 = 6;
    /// A property expected of the coin provided didn't hold
    const ECOIN: u64 = 7;
    /// The destruction of a non-zero coin was attempted. Non-zero coins must be burned.
    const EDESTRUCTION_OF_NONZERO_COIN: u64 = 8;
    /// A property expected of `MintCapability` didn't hold
    const EMINT_CAPABILITY: u64 = 9;
    /// A withdrawal greater than the value of the coin was attempted.
    const EAMOUNT_EXCEEDS_COIN_VALUE: u64 = 10;
    /// A property expected of the `PreburnQueue` resource didn't hold.
    const EPREBURN_QUEUE: u64 = 11;
    /// A preburn with a matching amount in the preburn queue was not found.
    const EPREBURN_NOT_FOUND: u64 = 12;

    /// The maximum number of preburn requests that can be outstanding for a
    /// given designated dealer/currency.
    const MAX_OUTSTANDING_PREBURNS: u64 = 256;

    public fun initialize(dr_account: &signer) {
        
    }
}