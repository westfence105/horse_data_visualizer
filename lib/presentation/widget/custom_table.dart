import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

abstract class CustomTableColumnDefinitionBase<T> {
  final String name;
  final double width;
  final MainAxisAlignment headerAlignment;

  CustomTableColumnDefinitionBase({
    required this.name,
    required this.width,
    this.headerAlignment = MainAxisAlignment.center,
  });

  Widget buildCell(BuildContext context, T rowData);
}

class CustomTableColumnDefinition<T> extends CustomTableColumnDefinitionBase<T> {
  final Widget Function(BuildContext context, T rowData) cellBuilder;

  CustomTableColumnDefinition({
    required super.name,
    required super.width,
    super.headerAlignment,
    required this.cellBuilder,
  });

  @override
  Widget buildCell(BuildContext context, T rowData)
    => cellBuilder(context, rowData);
}

class CustomTable<T> extends StatefulWidget {
  final List<T> data;
  final List<CustomTableColumnDefinitionBase<T>> columns;
  final double rowHeight;
  final double columnSpacing;
  final int? sortColumn;
  final bool? sortAscending;
  final List<int> sortableColumns;
  final void Function(int column, bool ascending)? onSort;
  final AlignmentGeometry alignment;

  const CustomTable({
    super.key,
    required this.data,
    required this.columns,
    this.rowHeight = 48,
    this.columnSpacing = 24,
    this.sortColumn,
    this.sortAscending,
    this.sortableColumns = const [],
    this.onSort,
    this.alignment = Alignment.topCenter,
  }) : assert(columns.length > 0);

  @override
  State<StatefulWidget> createState() => _CustomTableState<T>();
}

class _CustomTableState<T> extends State<CustomTable<T>> {
  final _verticalScrollController = ScrollController();

  double get _tableWidth
    => widget.columns.map((c) => c.width).reduce((a, b) => a + b);
  
  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: widget.alignment,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _tableWidth + 16,
        child: RawScrollbar(
          controller: _verticalScrollController,
          thumbVisibility: true,
          trackVisibility: false,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          padding: EdgeInsets.only(top: widget.rowHeight),
          child: TableView.builder(
            alignment: Alignment.topLeft,
            pinnedRowCount: 1,
            verticalDetails: ScrollableDetails.vertical(
              controller: _verticalScrollController,
            ),
            columnCount: widget.columns.length,
            rowCount: widget.data.length + 1,
            columnBuilder: (col) => TableSpan(
              extent: FixedSpanExtent(widget.columns[col].width),
            ),
            rowBuilder: (row) => TableSpan(
              extent: FixedSpanExtent(widget.rowHeight),
            ),
            cellBuilder: (context, vicinity) {
              final row = vicinity.row;
              final col = vicinity.column;

              late final Widget content;
              if (row == 0) {
                content = _buildHeaderCell(col);
              }
              else {
                content = widget.columns[col].buildCell(context, widget.data[row-1]);
              }
              return TableViewCell(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.columnSpacing * 0.5,
                  ),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _buildHeaderCell(int col) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      if (widget.onSort != null && widget.sortableColumns.contains(col)) {
        widget.onSort!(col, (widget.sortColumn == col) ? widget.sortAscending == false : true);
      }
    },
    child: Row(
      mainAxisAlignment: widget.columns[col].headerAlignment,
      children: [
        if (widget.sortColumn == col && widget.columns[col].headerAlignment == MainAxisAlignment.center)
          const SizedBox(width: 32),
        
        Text(widget.columns[col].name),

        if (widget.sortColumn == col)
          const SizedBox(width: 8),
        if (widget.sortColumn == col)
          Icon(
            (widget.sortAscending == true) ?
              Icons.arrow_drop_up : Icons.arrow_drop_down,
            size: 24,
          ),
      ],
    ),
  );
}

class StaticTableColumnDefinition<T> extends CustomTableColumnDefinitionBase<T> {
  final String Function(T rowData) valueBuilder;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? fontColor;
  final Alignment bodyAlignment;
  final TextDecoration? textDecoration;
  final TextStyle Function(T rowData, TextStyle baseStyle)? styleBuilder;

  StaticTableColumnDefinition({
    required super.name,
    required super.width,
    required this.valueBuilder,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.fontColor,
    this.textDecoration,
    super.headerAlignment,
    this.bodyAlignment = Alignment.center,
    this.styleBuilder,
  });

  @override
  Widget buildCell(BuildContext context, T rowData) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: fontColor,
      decoration: textDecoration,
    );
    return Container(
      width: width,
      alignment: bodyAlignment,
      child: Text(
        valueBuilder(rowData),
        style: styleBuilder != null ?
          styleBuilder!(rowData, baseStyle) : baseStyle,
      ),
    );
  }
}
