package Translator;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.tree.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import Translator.PlSqlParser.Column_nameContext;

public class PlSqlTranslator {
	private static final char TAB_CHAR = '\t';
	private static final char NEW_LINE_CHAR = '\n';

	public static class XMLEmitter extends PlSqlParserBaseListener {
		Map<String, List<ColumnProperty>> map = new HashMap();
		List<ColumnProperty> columnProperties = new ArrayList();
		String currentTable = "";

		public void exitCreate_table(PlSqlParser.Create_tableContext ctx) {
			String tableName = ctx.tableview_name().getText();
			map.put(tableName, columnProperties);
			currentTable = tableName;

			// reset ColumnProperties for a new table
			columnProperties = new ArrayList();
		}

		public void exitColumn_definition(PlSqlParser.Column_definitionContext ctx) {
			String columnName = ctx.column_name().getText();
			String datatype = ctx.datatype().getText();

			ColumnProperty column = new ColumnProperty();
			column.setColumnName(columnName);
			column.setColumnDataType(datatype);

			columnProperties.add(column);
		}

		public void exitOut_of_line_constraint(PlSqlParser.Out_of_line_constraintContext ctx) {
			if (ctx.PRIMARY() != null) {
				for (Column_nameContext key : ctx.column_name()) {
					String primaryKey = key.getText();

					ColumnProperty copy = null;

					List<ColumnProperty> columnProperties = map.get(currentTable);
					List<ColumnProperty> columnPropertiesCopy = new ArrayList();
					for (ColumnProperty val : columnProperties) {
						columnPropertiesCopy.add(val);
					}

					for (ColumnProperty column : columnProperties) {
						if (column.getColumnName().equals(primaryKey)) {
							copy = column;
							copy.setPrimaryKey(true);

							columnPropertiesCopy.remove(column);
							columnPropertiesCopy.add(copy);
							map.put(currentTable, columnPropertiesCopy);

						}
					}

				}
			}
		}

	}

	static String readFile(String path) throws IOException {
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, "UTF-8");
	}

	public static void main(String[] args) throws Exception {
		// create input stream `in`
		System.out.println("About to read from " + args[0]);
		ANTLRInputStream in = new ANTLRInputStream(readFile(args[0]));
		// create lexer `lex` with `in` at input
		Translator.PlSqlLexer lex = new Translator.PlSqlLexer(in);
		// create token stream `tokens` with `lex` at input
		CommonTokenStream tokens = new CommonTokenStream(lex);
		// create parser with `tokens` at input
		Translator.PlSqlParser parser = new Translator.PlSqlParser(tokens);
		// call start rule of parser
		ParseTree tree = parser.sql_script();
		// print func_name
//        System.out.println("Function names: "+parser.func_name);
		System.out.println("Grammar File Name: " + (parser.getGrammarFileName()));
		System.out.println("Token names: " + Arrays.toString(parser.getTokenNames()));
		System.out.println("Rule names: " + Arrays.toString(parser.getRuleNames()));

		ParseTreeWalker walker = new ParseTreeWalker();
		XMLEmitter converter = new XMLEmitter();
		walker.walk(converter, tree);

		StringBuilder changeSet = new StringBuilder();
		for (Map.Entry<String, List<ColumnProperty>> entry : converter.map.entrySet()) {
			changeSet.append(NEW_LINE_CHAR);
			String key = entry.getKey();
			changeSet.append(createTableStart(key));
			List<ColumnProperty> value = entry.getValue();
			for (ColumnProperty column : value) {
				if (column.isPrimaryKey()) {
					changeSet.append(columnWithConstraint(column));
				} else {
					changeSet.append(columnWithoutConstraint(column));
				}
			}

			changeSet.append(createTableEnd());

			changeSet.append(NEW_LINE_CHAR);
		}


	}

	private static String createTableStart(String tableName) {
		StringBuilder sb = new StringBuilder();
		sb.append("<createTable tableName=\"").append(tableName).append("\">");

		return sb.toString();
	}

	private static String createTableEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append("</createTable>");

		return sb.toString();
	}

	private static String columnWithConstraint(ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append("<column name=\"").append(column.getColumnName()).append("\" ").append("type=\"");

		convertColumnDataType(sb, column);

		sb.append("\">").append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR)
				.append("<constraints primaryKey=\"true\"").append("/>");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append("</column>");

		return sb.toString();
	}

	private static String columnWithoutConstraint(ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append("<column name=\"").append(column.getColumnName()).append("\" ").append("type=\"");

		convertColumnDataType(sb, column);

		sb.append("\"/>");

		return sb.toString();
	}

	private static void convertColumnDataType(StringBuilder sb, ColumnProperty column) {
		switch (column.getColumnDataType()) {
		case "NUMBER":
			sb.append("bigint");
			break;

		default:
			sb.append(column.getColumnDataType());
			break;
		}
	}

}