# Enhanced Data Profiling Tool for Power Query

## Overview
This project showcases an **Enhanced Data Profiling Tool** built for Power Platform Dataflows using Power Query (M language). The tool analyzes data quality and structure, providing detailed insights into column statistics, data completeness, and date ranges. It is designed with modularity and performance in mind, making it adaptable to various data sources such as SQL Server, Oracle, MySQL, Excel, and SharePoint.

This repository demonstrates my skills in:
- **Data Analysis**: Generating comprehensive data quality metrics like completeness percentages and sample values.
- **Power Query (M)**: Writing optimized, reusable, and well-documented code for data transformation and profiling.
- **Data Source Integration**: Connecting to Power Platform Dataflows with flexibility to adapt to other data sources.
- **Performance Optimization**: Implementing row limits and efficient data handling for large datasets.
- **Documentation**: Providing clear, professional code comments and configuration instructions.

## Features
- **Column-Level Analysis**: Calculates empty/null counts, non-empty counts, total rows, and completeness percentages for each column.
- **Sample Values**: Extracts up to a configurable number of valid sample values per column, excluding errors or invalid data.
- **Date Range Analysis**: Identifies the minimum and maximum dates in a specified date column (if provided).
- **Flexible Configuration**: Easily customizable for different entities, workspaces, and dataflows via configuration parameters.
- **Extensibility**: Supports adaptation to various data sources (e.g., SQL Server, Excel) with minimal code changes.
- **Performance Optimization**: Includes configurable row limits to improve processing speed for large datasets.

## Installation and Setup
### Prerequisites
- **Microsoft Power BI** or **Power Platform** with access to Dataflows.
- Power Query Editor to run the M code.
- Valid Workspace ID and Dataflow ID for Power Platform Dataflows (or credentials for alternative data sources).

### Usage
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/nox-magistralis/Power-Platform-Portfolio.git
   ```
2. **Configure Parameters**:
   - Open the Power Query script in Power BI or Power Query Editor.
   - Update the `CONFIGURATION SECTION` with your specific values:
     - `EntityName`: The name of the entity to analyze.
     - `WeekDateColumnName`: The name of the date column (leave blank if not applicable).
     - `MaxSampleValues`: Maximum number of sample values to display per column.
     - `Workspace`: Your Power Platform workspace ID.
     - `DataFlowID`: Your Dataflow ID.
     - `param-data-limit`: Set to `-1` for all rows or a positive number to limit rows for performance.

3. **Run the Script**:
   - Load the script into Power Query Editor.
   - Connect to your data source (default is Power Platform Dataflows).
   - Apply the query to generate the profiling report.

4. **Adapt for Other Data Sources** (Optional):
   - Modify the `DATA SOURCE CONNECTION` section to connect to alternative sources like SQL Server, Oracle, or Excel. For example, for SQL Server:
     ```m
     Source = Sql.Database("ServerName", "DatabaseName"),
     EntityData = Source{[Schema="SchemaName",Item="TableName"]}[Data]
     ```

## Code Structure
- **Configuration Section**: Defines user-configurable parameters for entity, workspace, and dataflow settings.
- **Data Source Connection**: Establishes connection to Power Platform Dataflows (or other sources with modification).
- **Data Extraction**: Retrieves and limits data for performance optimization.
- **Helper Functions**:
  - `IsEmptyValue`: Identifies empty or invalid values based on business rules.
  - `GetColumnStats`: Analyzes each column for statistics and sample values.
- **Column Statistics**: Generates a table with metrics like empty counts, non-empty counts, and completeness percentages.
- **Date Range Analysis**: Computes min/max dates for a specified date column.
- **Final Output**: Combines all results into a structured table with metadata and an index.

## Example Output
![Screenshot of Power Query output](https://github.com/nox-magistralis/Power-Platform-Portfolio/blob/powerquery/powerquery/enhanced-data-profiling-tool/assets/enhanced-data-profiling-tool-result.png?raw=true)

## Customization
- **Change Data Source**: Update the `Source` and `EntityData` steps to connect to other databases or file types.
- **Adjust Sample Size**: Modify `MaxSampleValues` to control the number of sample values displayed.
- **Row Limits**: Set `param-data-limit` to process a subset of rows for faster execution during testing.
- **Add New Metrics**: Extend `GetColumnStats` to include additional statistics like data type distribution or unique value counts.

## Future Enhancements
- Add support for automated data quality alerts based on completeness thresholds.
- Implement advanced statistical analysis (e.g., mean, median, standard deviation for numeric columns).
- Create a visualization layer in Power BI to display profiling results interactively.

## Author
**Marcin Mozol**  
Date: June 6, 2025  
Contact: marcin.mozol@pm.me

## License
This project is licensed under the MIT License. See the [LICENSE](https://github.com/nox-magistralis/Power-Platform-Portfolio/blob/powerquery/LICENSE) file for details.