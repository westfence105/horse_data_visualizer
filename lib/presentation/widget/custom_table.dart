
import 'dart:math';

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
  final _horizontalScrollController = ScrollController();

  double get _tableWidth
    => widget.columns.map((c) => c.width).reduce((a, b) => a + b);
  
  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: widget.alignment,
    child: RawScrollbar(
      thumbVisibility: true,
      trackVisibility: false,
      interactive: true,
      controller: _horizontalScrollController,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      padding: EdgeInsets.only(top: widget.rowHeight),
      child: SizedBox(
        width: _tableWidth + 16,
        child: RawScrollbar(
          thumbVisibility: true,
          trackVisibility: false,
          interactive: true,
          controller: _verticalScrollController,
          scrollbarOrientation: ScrollbarOrientation.right,
          padding: EdgeInsets.only(top: widget.rowHeight),
          child: TableView.builder(
            alignment: Alignment.topLeft,
            pinnedRowCount: 1,
            verticalDetails: ScrollableDetails.vertical(
              controller: _verticalScrollController,
            ),
            horizontalDetails: ScrollableDetails.horizontal(
              controller: _horizontalScrollController,
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
                content = Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.columnSpacing * 0.5,
                  ),
                  child: widget.columns[col].buildCell(context, widget.data[row-1]),
                );
              }
              return TableViewCell(
                child: content,
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _buildHeaderCell(int col) {
    final column = widget.columns[col];
    final sorted = widget.sortColumn == col;
    final center = column.headerAlignment == MainAxisAlignment.center;

    final content = Text(widget.columns[col].name);

    late final List<Widget> widgets;
    if (sorted) {
      late double spacing;
      if (center) {
        spacing = max(widget.columnSpacing * 0.5, 8);
      }
      else {
        spacing = widget.columnSpacing;
      }
      final sortIcon = SizedBox(
        width: 8,
        child: Icon(
          (widget.sortAscending == true) ?
            Icons.arrow_drop_up : Icons.arrow_drop_down,
        ),
      );
      widgets = [
        SizedBox(width: spacing),
        content,
        sortIcon,
      ];
      if (center) {
        widgets.add(SizedBox(width: spacing - 8));
      }
    }
    else {
      if (center) {
        widgets = [content];
      }
      else {
        widgets = [
          SizedBox(width: widget.columnSpacing * 0.5),
          content,
        ];
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.onSort != null && widget.sortableColumns.contains(col)) {
          widget.onSort!(col, sorted ? widget.sortAscending == false : true);
        }
      },
      child: SizedBox(
        width: column.width - widget.columnSpacing,
        child: Row(
        mainAxisAlignment: column.headerAlignment,
        children: widgets,
      ),
      ),
    );
  }
}

class StaticTableColumnDefinition<T> extends CustomTableColumnDefinitionBase<T> {
  final String Function(T rowData) valueBuilder;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? fontColor;
  final MainAxisAlignment bodyAlignment;
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
    this.bodyAlignment = MainAxisAlignment.center,
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
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: bodyAlignment,
        children: [
          Text(
            valueBuilder(rowData),
            style: styleBuilder != null ?
              styleBuilder!(rowData, baseStyle) : baseStyle,
          ),
        ],
      ),
    );
  }
}
