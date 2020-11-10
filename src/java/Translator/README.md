An ANTLR4 grammar for PL/SQL

ANTLR is code generator. It takes so called grammar file as input and generates two classes: lexer and parser.
Lexer runs first and splits input into pieces called tokens. Each token represents more or less meaningful piece of input. The stream of tokes is passed to parser which do all necessary work. It is the parser who builds abstract syntax tree, interprets the code or translate it into some other form.

## Usage, important note

As SQL grammar are normally not case sensitive but this grammar implementation is, you must use a custom [character stream](https://github.com/antlr/antlr4/blob/master/runtime/Java/src/org/antlr/v4/runtime/CharStream.java) that converts all characters to uppercase before sending them to the lexer.

You could find more information [here](https://github.com/antlr/antlr4/blob/master/doc/case-insensitive-lexing.md#custom-character-streams-approach) with implementations for various target languages.


