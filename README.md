# Ruby Source Maps

## Usage

**Concatenation**

``` ruby
foo = File.read("examples/foo.js")
bar = File.read("examples/bar.js")
foobar = foo + bar

foo_map = SourceMap::Map.from_json File.read("examples/foo.map")
bar_map = SourceMap::Map.from_json File.read("examples/bar.map")
foobar_map = foo_map + bar_map
foobar_map.to_json
```
