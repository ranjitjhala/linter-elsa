# linter-elsa

This package will check your opened ELSA file in Atom,
using [elsa](http://www.github.com/ucsd-progsys/elsa)

## Installation

* Install [elsa](http://www.github.com/ucsd-progsys/elsa)

* `$ apm install linter` (if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
* `$ apm install language-haskell` (if you don't have [Haskell syntax highlighting](https://github.com/jroesch/language-haskell) installed).
* `$ apm install linter-elsa`

* Specify the path to `elsa` in the settings; find the path by using `which elsa` in the terminal.

Add this to your `config.cson`

```yaml
core:
  customFileTypes:
    "source.haskell": [
      "lc"
    ]
```

