package IgniteTranslator;

import Translator.ColumnProperty;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.tree.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
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
 * The changeset.xml generated from this translator has been verifid for Ignite
 */

public class PlSqlIgniteTranslator {
	private static final char TAB_CHAR = '\t';
	private static final char NEW_LINE_CHAR = '\n';
	private static boolean firstColumn = true;

	public static class XMLEmitter extends PlSqlParserBaseListener {
		Map<String, List<Translator.ColumnProperty>> map = new HashMap();
		List<Translator.ColumnProperty> columnProperties = new ArrayList();
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

			Translator.ColumnProperty column = new Translator.ColumnProperty();
			column.setColumnName(columnName);
			column.setColumnDataType(datatype);

			if (ctx.inline_constraint() != null) {
				System.out.println(ctx.inline_constraint().toString());
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

					Translator.ColumnProperty copy = null;

					List<Translator.ColumnProperty> columnProperties = map.get(currentTable);
					List<Translator.ColumnProperty> columnPropertiesCopy = new ArrayList();
					for (Translator.ColumnProperty val : columnProperties) {
						columnPropertiesCopy.add(val);
					}

					for (Translator.ColumnProperty column : columnProperties) {
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

			if (ctx.constraint_state() != null) {
				for (Column_nameContext key : ctx.column_name()) {
					String primaryKey = key.getText();

					Translator.ColumnProperty copy = null;

					List<Translator.ColumnProperty> columnProperties = map.get(currentTable);
					List<Translator.ColumnProperty> columnPropertiesCopy = new ArrayList();
					for (Translator.ColumnProperty val : columnProperties) {
						columnPropertiesCopy.add(val);
					}

					for (Translator.ColumnProperty column : columnProperties) {
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

	private static String readFile(String path) throws IOException {
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, "UTF-8");
	}

	public static void main(String[] args) throws IOException {
		String inputFile = null;
		if (args.length > 0)
			inputFile = args[0];
		InputStream is = System.in;
		if (inputFile != null) {
			is = new FileInputStream(inputFile);
		}
		ANTLRInputStream in = new ANTLRInputStream(is);

		PlSqlLexer lexer = new PlSqlLexer(in);

		PlSqlParser parser = new PlSqlParser(new CommonTokenStream(lexer));

		ParseTree tree = parser.sql_script();

		ParseTreeWalker walker = new ParseTreeWalker();
		XMLEmitter converter = new XMLEmitter();
		walker.walk(converter, tree);

		System.out.println(tree.toStringTree(parser));

		for (Map.Entry<String, List<Translator.ColumnProperty>> entry : converter.map.entrySet()) {
			String key = entry.getKey();
			List<Translator.ColumnProperty> value = entry.getValue();
			for (Translator.ColumnProperty column : value) {
				System.out.println("value:" + column.toString());

			}
		}

		StringBuilder changeSet = new StringBuilder();

		// Construct createTable
		for (Map.Entry<String, List<Translator.ColumnProperty>> entry : converter.map.entrySet()) {
			changeSet.append(NEW_LINE_CHAR).append(NEW_LINE_CHAR);
			String key = entry.getKey();
			changeSet.append(createTableStart(key));
			List<Translator.ColumnProperty> value = entry.getValue();
			
			firstColumn = true;
			for (Translator.ColumnProperty column : value) {
				changeSet.append(constructColumn(column));
			}

			// Add primary key constraint at the end
			for (Translator.ColumnProperty column : value) {
				if (column.isPrimaryKey()) {
					changeSet.append(primaryKeyConstraint(key, column));
				}
			}

			changeSet.append(createTableEnd());

		}

		PrintWriter out = new PrintWriter("changeSet.ignite.sql");
		out.println(changeSet.toString());
		out.close();
	}

	/**
	 * Construct createTable with schema Starting
	 * 
	 * @param tableName
	 * @return
	 */
	private static String createTableStart(String tableName) {
		String[] schemeTable = tableName.split("\\.");
		String schema = schemeTable[0];
		String table = schemeTable[1];
		StringBuilder sb = new StringBuilder();
		sb.append("CREATE TABLE ").append("SQL_").append(schema).append("_").append(table).append(" (");

		return sb.toString();
	}

	/**
	 * Construct createTable Ending
	 * 
	 * @return
	 */
	private static String createTableEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(");");

		return sb.toString();
	}

	/**
	 * Construct column
	 * 
	 * @param column
	 * @return
	 */
	private static String constructColumn(Translator.ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		
		// Don't add , if it is first column
		if(!firstColumn) {
			sb.append(",");
		}
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append(column.getColumnName() + " ");

		convertColumnDataType(sb, column);
		firstColumn = false;
		return sb.toString();
	}

	private static String primaryKeyConstraint(String tableName, Translator.ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(",");
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append("CONSTRAINT ").append(tableName.split("\\.")[1]).append("_PK ").append("PRIMARY KEY").append("(");
		sb.append(column.getColumnName()).append(")");

		return sb.toString();
	}

	/**
	 * Convert from Oracle ddl datatype to changeset datatype
	 * 
	 * @param sb
	 * @param column
	 */
	private static void convertColumnDataType(StringBuilder sb, ColumnProperty column) {
		if(column.getColumnDataType().contains("VARCHAR")) {
			sb.append("VARCHAR");
		} else if(column.getColumnDataType().contains("NUMBER")) {
			sb.append("BIGINT");
		}
		else {
			sb.append(column.getColumnDataType());
		}	
	}

}