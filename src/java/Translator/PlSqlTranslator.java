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
import java.io.PrintWriter;
import Translator.PlSqlParser.Column_nameContext;
import Translator.PlSqlParser.Inline_constraintContext;

/*
 * The changeset.xml generated from this translator has been verifid for Postgres, MySQL, and Oracle
 */

public class PlSqlTranslator {
	private static final char TAB_CHAR = '\t';
	private static final char NEW_LINE_CHAR = '\n';
	private static final String schemaName = "CE";

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

			String expression = "";
			// Default value for column
			if (ctx.expression() != null) {
				expression = ctx.expression().getText();
			}

			ColumnProperty column = new ColumnProperty();
			column.setColumnName(columnName);
			column.setColumnDataType(datatype);

			if (expression.equals("USER")) {
				column.setDefaultValue("DEFAULT USER");
			} else if (expression.equals("SYSTIMESTAMP")) {
				column.setDefaultValueComputed("CURRENT_TIMESTAMP");
			}

			if (ctx.inline_constraint() != null) {
				for (Inline_constraintContext inlineConstraint : ctx.inline_constraint()) {
					if (inlineConstraint.getText().equals("NOTNULLENABLE")) {
						column.setNotNullEnable(true);
					}
				}
			}

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
		changeSet.append(xmlDeclaration());
		changeSet.append(databaseChangeLogStart());
		changeSet.append(changeSetStart());

		// Construct createTable xml
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

		}

		// Construct addNotNullConstraint xml
		for (Map.Entry<String, List<ColumnProperty>> entry : converter.map.entrySet()) {
			String key = entry.getKey();
			List<ColumnProperty> value = entry.getValue();
			for (ColumnProperty column : value) {
				if (column.isNotNullEnable()) {
					constructAddNotNullConstraint(changeSet, key, column);
				}
			}
		}

		changeSet.append(changeSetEnd());
		changeSet.append(databaseChangeLogEnd());

		PrintWriter out = new PrintWriter("changeSet.xml");
		out.println(changeSet.toString());
		out.close();

	}

	/**
	 * Construct createTable with schema Starting xml
	 * 
	 * @param tableName
	 * @return
	 */
	private static String createTableStart(String tableName) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("<createTable tableName=\"").append(tableName)
				.append("\"");
		sb.append(" schemaName=\"").append(schemaName).append("\">");

		return sb.toString();
	}

	/**
	 * Construct createTable Ending xml
	 * 
	 * @return
	 */
	private static String createTableEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("</createTable>");

		return sb.toString();
	}

	/**
	 * Construct column xml with primary key constraint
	 * 
	 * @param column
	 * @return
	 */
	private static String columnWithConstraint(ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR);

		sb.append("<column name=\"").append(column.getColumnName()).append("\" ").append("type=\"");

		convertColumnDataType(sb, column);
		if (column.getDefaultValue() != null || column.getDefaultValueComputed() != null) {
			sb.append("\"");
		}

		constructDefaultValue(sb, column);

		constructDefaultValueComputed(sb, column);

		sb.append("\">").append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR)
				.append("<constraints primaryKey=\"true\"").append("/>");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("</column>");

		return sb.toString();
	}

	/**
	 * Construct column xml without primary key constraint
	 * 
	 * @param column
	 * @return
	 */
	private static String columnWithoutConstraint(ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR);

		sb.append("<column name=\"").append(column.getColumnName()).append("\" ").append("type=\"");

		convertColumnDataType(sb, column);
		if (column.getDefaultValue() != null || column.getDefaultValueComputed() != null) {
			sb.append("\"");
		}

		constructDefaultValue(sb, column);

		constructDefaultValueComputed(sb, column);

		sb.append("\"/>");

		return sb.toString();
	}

	/**
	 * Convert from Oracle ddl datatype to liquibase changeset datatype
	 * 
	 * @param sb
	 * @param column
	 */
	private static void convertColumnDataType(StringBuilder sb, ColumnProperty column) {
		switch (column.getColumnDataType()) {
		case "NUMBER":
			sb.append("bigint");
			break;

		case "TIMESTAMP(6)":
			sb.append("TIMESTAMP");
			break;

		default:
			sb.append(column.getColumnDataType());
			break;
		}
	}

	/**
	 * Construct xml declaration
	 * 
	 * @return
	 */
	private static String xmlDeclaration() {
		StringBuilder sb = new StringBuilder();
		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		sb.append(NEW_LINE_CHAR);
		return sb.toString();
	}

	/**
	 * Construct databaseChangeLog Starting xml
	 * 
	 * @return
	 */
	private static String databaseChangeLogStart() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append("<databaseChangeLog");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append("xmlns=\"http://www.liquibase.org/xml/ns/dbchangelog\"");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append("xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR)
				.append("xsi:schemaLocation=\"http://www.liquibase.org/xml/ns/dbchangelog");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR)
				.append("http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd\">");

		sb.append(NEW_LINE_CHAR);
		return sb.toString();
	}

	/**
	 * Construct databaseChangeLog Ending xml
	 * 
	 * @return
	 */
	private static String databaseChangeLogEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(NEW_LINE_CHAR).append("</databaseChangeLog>");
		return sb.toString();
	}

	/**
	 * Construct changeSet Starting xml
	 * 
	 * @return
	 */
	private static String changeSetStart() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append("<changeSet  id=\"1\"  author=\"ce\">");
		return sb.toString();
	}

	/**
	 * Construct changeSet Ending xml
	 * 
	 * @return
	 */
	private static String changeSetEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(NEW_LINE_CHAR).append(TAB_CHAR).append("</changeSet>");
		return sb.toString();
	}

	private static void constructDefaultValue(StringBuilder sb, ColumnProperty column) {
		if (column.getDefaultValue() != null) {
			sb.append(" defaultValue=\"" + column.getDefaultValue());
		}
	}

	private static void constructDefaultValueComputed(StringBuilder sb, ColumnProperty column) {
		if (column.getDefaultValueComputed() != null) {
			sb.append(" defaultValueComputed=\"" + column.getDefaultValueComputed());
		}
	}

	/**
	 * Construct NOT NULL constraint for a column in xml
	 * 
	 * @param sb
	 * @param schemaTable
	 * @param column
	 */
	private static void constructAddNotNullConstraint(StringBuilder sb, String schemaTable, ColumnProperty column) {
		String[] tableSchema = schemaTable.split("\\.");
		String schema = tableSchema[0];
		String tableName = tableSchema[1];
		String columnName = column.getColumnName();
		String columnDataType = column.getColumnDataType();

		sb.append(NEW_LINE_CHAR).append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR)
				.append("<addNotNullConstraint");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("columnName=\"")
				.append(columnName).append("\"");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("schemaName=\"")
				.append(schema).append("\"");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("columnDataType=\"")
				.append(columnDataType).append("\"");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR).append(TAB_CHAR).append(TAB_CHAR).append("tableName=\"")
				.append(tableName).append("\"").append("/>");

	}

}