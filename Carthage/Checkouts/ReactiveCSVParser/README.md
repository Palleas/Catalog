# ReactiveCSVParser

## Installation

I guess at some point you could simply put ``Palleas/ReactiveCSVParser`` in a Cartfile.

## Getting the code 

You'll need [Carthage](http://github.com/Carthage/Carthage) to install the dependencies.

  $ git clone git@github.com:Palleas/ReactiveCSVParser.git
  $ carthage bootstrap

## Limitations

For now it's a **really** naive approach first splitting the content into line based on the newline character, 
then splitting each lines into columns based on the comma character.

## License 

See [LICENSE](https://github.com/Palleas/ReactiveCSVParser/blob/master/LICENSE) file.
