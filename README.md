## Move Learning

Install Move Cli
```sh
sudo cargo install --git https://github.com/diem/move move-cli --branch main
```
Note: `cargo install --git https://github.com/diem/diem move-cli` will get error. I don't know why, here is the issue link: https://github.com/diem/diem/issues/10349

Compile
```sh
move sandbox publish -p sources/generics.move
```

Unit Test
```sh
move package test -p sources/unit_test.move
```

Note: There is bug when executes unit test. The MoveStdlib unit test files' name is not matched with modules, you have to change the name to solve the problem. Good luck with you. >_<

