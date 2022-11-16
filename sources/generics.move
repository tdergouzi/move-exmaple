/*
    Move - Generics

    Generics can be used to define functions and structs over different input data types.
*/ 

module example::Generics {
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
}