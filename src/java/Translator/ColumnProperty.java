package Translator;

public class ColumnProperty {
	private String columnName;
	private String columnDataType;
	private String defaultValue;
	private String defaultValueComputed;
	private boolean isPrimaryKey;

	public String getColumnName() {
		return columnName;
	}

	public void setColumnName(String columnName) {
		this.columnName = columnName;
	}

	public String getColumnDataType() {
		return columnDataType;
	}

	public void setColumnDataType(String columnDataType) {
		this.columnDataType = columnDataType;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getDefaultValueComputed() {
		return defaultValueComputed;
	}

	public void setDefaultValueComputed(String defaultValueComputed) {
		this.defaultValueComputed = defaultValueComputed;
	}

	public boolean isPrimaryKey() {
		return isPrimaryKey;
	}

	public void setPrimaryKey(boolean isPrimaryKey) {
		this.isPrimaryKey = isPrimaryKey;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((columnDataType == null) ? 0 : columnDataType.hashCode());
		result = prime * result + ((columnName == null) ? 0 : columnName.hashCode());
		result = prime * result + ((defaultValue == null) ? 0 : defaultValue.hashCode());
		result = prime * result + ((defaultValueComputed == null) ? 0 : defaultValueComputed.hashCode());
		result = prime * result + (isPrimaryKey ? 1231 : 1237);
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ColumnProperty other = (ColumnProperty) obj;
		if (columnDataType == null) {
			if (other.columnDataType != null)
				return false;
		} else if (!columnDataType.equals(other.columnDataType))
			return false;
		if (columnName == null) {
			if (other.columnName != null)
				return false;
		} else if (!columnName.equals(other.columnName))
			return false;
		if (defaultValue == null) {
			if (other.defaultValue != null)
				return false;
		} else if (!defaultValue.equals(other.defaultValue))
			return false;
		if (defaultValueComputed == null) {
			if (other.defaultValueComputed != null)
				return false;
		} else if (!defaultValueComputed.equals(other.defaultValueComputed))
			return false;
		if (isPrimaryKey != other.isPrimaryKey)
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "ColumnProperty [columnName=" + columnName + ", columnDataType=" + columnDataType + ", defaultValue="
				+ defaultValue + ", defaultValueComputed=" + defaultValueComputed + ", isPrimaryKey=" + isPrimaryKey
				+ "]";
	}

}