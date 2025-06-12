let
    // ==============================================
    // ENHANCED DATA PROFILING TOOL FOR POWER QUERY
    // ==============================================
    // Purpose: Analyzes data quality and structure from Power Platform Dataflows
    // Author: Marcin Mozol
    // Date: 6-June-2025
    // Licence:  MIT License Copyright (c) 2025 Marcin Mozol
    // ==============================================
    // Author Note: This tool can be easily modified to connect to other data sources:
    // - SQL Server: Replace DATA SOURCE CONNECTION section with:
    //   Source = Sql.Database("ServerName", "DatabaseName"),
    //   EntityData = Source{[Schema="SchemaName",Item="TableName"]}[Data]
    // - Other sources: Oracle, MySQL, Excel, SharePoint, etc. can be used by
    //   changing the Source connection and EntityData extraction accordingly
    // ==============================================

    // CONFIGURATION SECTION
    // ==============================================
    EntityName = "your_entity_name", // Replace with your entity name
    WeekDateColumnName = "week_date", // Replace with your date column name, if you don't have one please leave it blank ""
    MaxSampleValues = 5, // Max number of samples per column
    Workspace = "your_workspace_id", // Replace with your Workspace ID
    DataFlowID = "your_dataflow_id", // Replace with your DataFlow ID
    
    // DATA SOURCE CONNECTION
    // ==============================================
    Source = PowerPlatform.Dataflows(null),
    Workspaces = Source{[Id="Workspaces"]}[Data],
    SelectedWorkspace = Workspaces{[workspaceId=Workspace]}[Data],
    SelectedDataflow = SelectedWorkspace{[dataflowId=DataFlowID]}[Data],
    
    // DATA EXTRACTION WITH PERFORMANCE OPTIMIZATION
    // ==============================================
    EntityData = SelectedDataflow{[entity=EntityName,version=""]}[Data],
    
    // Apply row limit for performance (configurable via parameter)
    // Examples: param-data-limit = 1 (processes 1 row), = 100 (processes 100 rows), = -1 (processes all rows)
    LimitedData = if #"param-data-limit" = -1 then EntityData else Table.FirstN(EntityData, #"param-data-limit"),
    
    // Get schema information
    ColumnNames = Table.ColumnNames(LimitedData),
    TotalRows = Table.RowCount(LimitedData),
    
    // HELPER FUNCTIONS
    // ==============================================
    // Checks if a value is considered "empty" based on business rules
    IsEmptyValue = (value) as logical =>
        value = null or 
        value = "" or 
        value = 0 or 
        (Type.Is(Value.Type(value), type text) and 
         (Text.Trim(value) = "" or Text.Upper(Text.Trim(value)) = "N/A")),
    
    // MAIN COLUMN ANALYSIS FUNCTION
    // ==============================================
    GetColumnStats = (table as table, columnName as text) as record =>
        let
            totalRows = Table.RowCount(table),
            
            // Count various types of empty/invalid values
            emptyBlankZeroNullRows = Table.SelectRows(table, each IsEmptyValue(Record.Field(_, columnName))),
            emptyBlankZeroNullCount = Table.RowCount(emptyBlankZeroNullRows),
            
            // Count valid values
            nonEmptyRows = Table.SelectRows(table, each not IsEmptyValue(Record.Field(_, columnName))),
            nonEmptyCount = Table.RowCount(nonEmptyRows),
            
            // Calculate data completeness percentage (as actual percentage, not decimal)
            completenessPercentage = if totalRows = 0 then 0 else (nonEmptyCount / totalRows),
            
            // Generate sample values (excluding errors and invalid data)
            validSampleRows = Table.SelectRows(table, each 
                let value = Record.Field(_, columnName)
                in not IsEmptyValue(value) and
                   not (Type.Is(Value.Type(value), type text) and 
                        Text.Start(Text.Upper(Text.Trim(value)), 6) = "#ERROR")
            ),
            
            sampleRows = Table.FirstN(validSampleRows, MaxSampleValues),
            columnValues = Table.Column(sampleRows, columnName),
            
            // Generate sample values as comma-separated text
            sampleText = Text.Combine(List.Transform(columnValues, each Text.From(_)), ", ")
        in
            [
                ColumnName = columnName,
                EmptyBlankZeroNullCount = emptyBlankZeroNullCount,
                NonEmptyCount = nonEmptyCount,
                TotalCount = totalRows,
                CompletenessPercentage = completenessPercentage,
                SampleValues = sampleText
            ],
    
    // GENERATE COLUMN STATISTICS
    // ==============================================
    ColumnStats = List.Transform(ColumnNames, each GetColumnStats(LimitedData, _)),
    StatsTable = Table.FromRecords(ColumnStats, 
        {"ColumnName", "EmptyBlankZeroNullCount", "NonEmptyCount", "TotalCount", "CompletenessPercentage", "SampleValues"}),
    
    // Transform CompletenessPercentage to proper percentage type
    StatsTableWithPercentage = Table.TransformColumns(StatsTable, {{"CompletenessPercentage", each _, Percentage.Type}}),
    
    // Add metadata columns
    StatsWithMetadata = Table.AddColumn(
        Table.AddColumn(StatsTableWithPercentage, "TableName", each EntityName, type text),
        "AnalysisDate", each DateTime.LocalNow(), type datetime
    ),
    
    // DATE RANGE ANALYSIS
    // ==============================================
    DateStats = if List.Contains(ColumnNames, WeekDateColumnName) then
        let
            weekDates = List.Select(Table.Column(LimitedData, WeekDateColumnName), each _ <> null),
            textDates = List.Transform(weekDates, each Text.From(_)),
            minDate = List.Min(textDates),
            maxDate = List.Max(textDates)
        in
            [minWeekDate = minDate, maxWeekDate = maxDate]
    else
        [minWeekDate = null, maxWeekDate = null],
    
    // FINAL OUTPUT ASSEMBLY
    // ==============================================
    StatsWithDates = Table.Combine({
        StatsWithMetadata,
        Table.FromRecords({
            [ColumnName = "DATA_RANGE_MIN", EmptyBlankZeroNullCount = null, NonEmptyCount = null, 
             TotalCount = null, CompletenessPercentage = null, SampleValues = DateStats[minWeekDate], 
             TableName = EntityName, AnalysisDate = DateTime.LocalNow()],
            [ColumnName = "DATA_RANGE_MAX", EmptyBlankZeroNullCount = null, NonEmptyCount = null, 
             TotalCount = null, CompletenessPercentage = null, SampleValues = DateStats[maxWeekDate], 
             TableName = EntityName, AnalysisDate = DateTime.LocalNow()]
        })
    }),
    
    // Add index and reorder columns
    FinalResult = Table.ReorderColumns(
        Table.AddIndexColumn(StatsWithDates, "Index", 1, 1, Int64.Type),
        {"Index", "ColumnName", "EmptyBlankZeroNullCount", "NonEmptyCount", "TotalCount", 
         "CompletenessPercentage", "SampleValues", "TableName", "AnalysisDate"}
    )

in 
    FinalResult