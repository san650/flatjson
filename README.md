# flatjson

Bash function to flatten json documents for easy processing.

## Synopsis

Create a script `./json.sh` and include `flatjson`

```sh
$ # Create a ./json.sh script
$ cat <<EOT > ./json.sh
#!/usr/bin/env bash
source "./flatjson.bash"
flatjson "$1"
EOT
$ # Give it execution permissions
$ chmod +x ./json.sh
$ # Use it!
$ ./json.sh '{ "hello": "world" }'
hello: world
$ # With nested objects
$ ./flatjson.bash '{ "foo": { "bar": "baz", "qux": "quxx" } }'
foo.bar: baz
foo.qux: quxx
```

## License

`flatjson` is licensed under the MIT license.

See [LICENSE](./LICENSE) for the full license text.
