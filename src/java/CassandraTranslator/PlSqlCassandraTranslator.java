package CassandraTranslator;

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
 * The changeset.xml generated from this translator has been verifid for Cassandra
 */

public class PlSqlCassandraTranslator {
	private static final char TAB_CHAR = '\t';
	private static final char NEW_LINE_CHAR = '\n';
	private static int mapValuesCount = 0;
	private static int mapValuesSize = 0;
	private static int changeSetCount = 0;

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
		changeSet.append(createHeader());

		boolean hasPrimaryKey = false;
		boolean isFirstColumn = true;

		// Construct createTable
		for (Map.Entry<String, List<Translator.ColumnProperty>> entry : converter.map.entrySet()) {
			mapValuesCount = 0;
			changeSet.append(NEW_LINE_CHAR).append(NEW_LINE_CHAR);
			changeSet.append(createChangeSetCount(++changeSetCount));
			String key = entry.getKey();
			changeSet.append(createTableStart(key));
			List<Translator.ColumnProperty> value = entry.getValue();

			// Check if there is primary key in table
			hasPrimaryKey = CheckPrimaryKeyExisting(value);
			isFirstColumn = true;

			mapValuesSize = value.size();
			for (Translator.ColumnProperty column : value) {
				mapValuesCount++;
				// make first column as primary key for now if no primary key from Oracle DDL
				if (column.isPrimaryKey() || (!hasPrimaryKey && isFirstColumn)) {
					changeSet.append(columnWithConstraint(column));
				} else {
					changeSet.append(columnWithoutConstraint(column));
				}

				isFirstColumn = false;
			}

			changeSet.append(createTableEnd());
			changeSet.append(createRollback(key));

		}

		PrintWriter out = new PrintWriter("changeSet.cassandra.sql");
		out.println(changeSet.toString());
		out.close();

	}

	private static String createHeader() {
		StringBuilder sb = new StringBuilder();
		sb.append("--liquibase formatted sql").append(NEW_LINE_CHAR).append(NEW_LINE_CHAR);

		return sb.toString();
	}

	private static String createChangeSetCount(int count) {
		StringBuilder sb = new StringBuilder();
		sb.append("--changeset CE:").append(count).append(NEW_LINE_CHAR);

		return sb.toString();
	}

	private static String createRollback(String tableName) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append("--rollback DROP TABLE ").append(tableName).append(";").append(NEW_LINE_CHAR);

		return sb.toString();
	}

	/**
	 * Construct createTable with schema Starting
	 * 
	 * @param tableName
	 * @return
	 */
	private static String createTableStart(String tableName) {
		StringBuilder sb = new StringBuilder();
		sb.append("CREATE TABLE ").append(tableName).append(" (");

		return sb.toString();
	}

	/**
	 * Construct createTable Ending
	 * 
	 * @return
	 */
	private static String createTableEnd() {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(")");

		return sb.toString();
	}

	/**
	 * Construct column with primary key constraint
	 * 
	 * @param column
	 * @return
	 */
	private static String columnWithConstraint(Translator.ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append(column.getColumnName() + " ");

		convertColumnDataType(sb, column);

		sb.append(" PRIMARY KEY");

		if (mapValuesCount != mapValuesSize) {
			sb.append(",");
		}

		return sb.toString();
	}

	/**
	 * Construct column without primary key constraint
	 * 
	 * @param column
	 * @return
	 */
	private static String columnWithoutConstraint(Translator.ColumnProperty column) {
		StringBuilder sb = new StringBuilder();
		sb.append(NEW_LINE_CHAR).append(TAB_CHAR);

		sb.append(column.getColumnName() + " ");

		convertColumnDataType(sb, column);

		if (mapValuesCount != mapValuesSize) {
			sb.append(",");
		}

		return sb.toString();
	}

	/**
	 * Convert from Oracle ddl datatype to liquibase changeset datatype
	 * 
	 * @param sb
	 * @param column
	 */
	private static void convertColumnDataType(StringBuilder sb, Translator.ColumnProperty column) {
		String dataType = column.getColumnDataType();
		if (dataType.contains("NUMBER")) {
			sb.append("BIGINT");
		} else if (dataType.contains("DATE")) {
			sb.append("DATE");
		} else if (dataType.contains("VARCHAR") || dataType.contains("CHAR")) {
			sb.append("VARCHAR");
		} else if (dataType.contains("TIMESTAMP")) {
			sb.append("TIMESTAMP");
		}
	}

	private static boolean CheckPrimaryKeyExisting(List<Translator.ColumnProperty> columns) {
		boolean hasPrimaryKey = false;

		for (ColumnProperty column : columns) {
			if (column.isPrimaryKey()) {
				hasPrimaryKey = true;
				break;
			}
		}

		return hasPrimaryKey;
	}

}