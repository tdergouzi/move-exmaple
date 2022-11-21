/*
    Move - Global Storage Operators

    1. Type T
    Type T must has `key` ability
    Each type T must be declared in the current module

    2. acquires
    A Move function `M::f` must be annotated with `acquires` if and only if:
    - The body of M::f contains a move_from<T>, borrow_global_mut<T>, or borrow_global<T> instruction
    - The body of M::f invokes a function M::g declared in the same module that is annotated with acquires
*/

module MoveLanguage::Counter {
    use Std::Signer;

    /// type T must has key ability
    struct Counter has key {i: u64}

    /// write
    /// move_to<T>(&signer,T)
    /// Publish T under signer.address
    public fun publish(account: &signer, i: u64) {
        move_to(account, Counter{i})
    }

    /// read
    /// borrow_global<T>(address): &T
    /// Return an immutable reference to the T stored under address
    public fun get_count(addr: address): u64 acquires Counter {
        borrow_global<Counter>(addr).i
    }

    /// update
    /// borrow_global_mut<T>(address): &mut T
    /// Return a mutable reference to the T stored under address
    public fun increment(addr: address) acquires Counter {
        let c_ref = &mut borrow_global_mut<Counter>(addr).i;
        *c_ref = *c_ref + 1
    }

    /// reset
    /// borrow_global_mut<T>(address): &mut T
    /// Return a mutable reference to the T stored under address
    public fun reset(account: &signer) acquires Counter {
        let c_ref = &mut borrow_global_mut<Counter>(Signer::address_of(account)).i;
        *c_ref = 0
    }

    /// delete
    /// move_from<T>(address): T
    /// Remove T from address and return it
    public fun delete(account: &signer): u64 acquires Counter {
        let c = move_from<Counter>(Signer::address_of(account));
        let Counter { i } = c;
        i
    }

    /// check
    /// exists<T>(address): bool
    /// Return true if a T is stored under address
    public fun check(addr: address): bool {
        exists<Counter>(addr)
    }

    fun call_increment(addr: address) acquires Counter {
        increment(addr)
    }
}

module MoveLanguage::OutOfCounter {
    use MoveLanguage::Counter;

    fun call_increment(addr: address) {
        Counter::increment(addr)
    }
}