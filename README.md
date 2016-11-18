### Usage
```bash
./build
./find . 'foo*'
```
### Description
Given a directory and an optional regex, print all files below the given
directory. If a regex is supplied, only print the path if it matches the regex.
Performance is near equivalent to the default `find .` on osx.

### Comment
I created this program because I was tired of `find . | grep 'foo'` failing on
large input sizes.

