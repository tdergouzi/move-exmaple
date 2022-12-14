/*
    Move - Generics

    Generics can be used to define functions and structs over different input data types.
*/ 

module MoveLanguage::Generics {
    public fun id<T>(x: T): T {
        (x: T)
    }

    struct Foo<T> has copy, drop {
        x: T
    }
 
    struct Foo1<phantom T> has copy,drop {
        x: u64
    }

    struct Bar<T1, T2> has copy, drop {
        x: T1,
        y: vector<T2>,
    }

    struct Currency1 {}
    struct Currency2 {}

    struct Coin<Currency> has store {
        value: u64
    }

    public fun mint_generic<Currency>(value: u64): Coin<Currency> {
        Coin { value }
    }

    public fun mint_concrete(value: u64): Coin<Currency1> {
        Coin { value }
    }
}