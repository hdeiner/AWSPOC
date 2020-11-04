package Translator;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.tree.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

public class PlSqlTranslator {
    static String readFile(String path) throws IOException
    {
        byte[] encoded = Files.readAllBytes(Paths.get(path));
        return new String(encoded, "UTF-8");
    }

    public static void main(String[] args) throws Exception {
        // create input stream `in`
        System.out.println("About to read from "+args[0]);
        ANTLRInputStream in = new ANTLRInputStream( readFile(args[0]) );
        // create lexer `lex` with `in` at input
        Translator.PlSqlLexer lex = new Translator.PlSqlLexer(in);
        // create token stream `tokens` with `lex` at input
        CommonTokenStream tokens = new CommonTokenStream(lex);
        // create parser with `tokens` at input
        Translator.PlSqlParser parser = new Translator.PlSqlParser(tokens);
        // call start rule of parser
        parser.sql_script();
        // print func_name
//        System.out.println("Function names: "+parser.func_name);
        System.out.println("Grammar File Name: "+ (parser.getGrammarFileName()));
        System.out.println("Token names: "+ Arrays.toString(parser.getTokenNames()));
        System.out.println("Rule names: "+ Arrays.toString(parser.getRuleNames()));




    }
}