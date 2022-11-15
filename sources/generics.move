module example::generics {

    // Function takes a value of any type and return the value unchanged.
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