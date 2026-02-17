import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_todo_app/constants/app_colors.dart';

class TaskSection extends StatefulWidget {
  final String id;
  final int index;
  final String initialText;
  final Function(String) onTextChanged;
  final bool isDragging;
  final VoidCallback? onToggleCompleted;
  final bool isCompleted;
  final Function(String)? onSubmitted;

  const TaskSection({
    super.key,
    required this.id,
    required this.index,
    required this.onTextChanged,
    this.initialText = '',
    this.isDragging = false,
    this.onToggleCompleted,
    this.isCompleted = false,
    this.onSubmitted,
  });

  @override
  State<TaskSection> createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  bool _isDeleted = false;

  final taskStyle = GoogleFonts.poppins(
    color: AppColors.primaryColor,
    fontSize: 18,
    height: 1.2,
  );

  void _handleDelete() async {
    if (_isDeleted) return;
    setState(() => _isDeleted = true);
    await Future.delayed(const Duration(milliseconds: 300));
    widget.onTextChanged("");
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _isEditing = false);
        if (_controller.text.trim().isEmpty && widget.id != 'new') {
          _handleDelete();
        }
      }
    });
  }

  @override
  void didUpdateWidget(TaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText && !_isEditing) {
      _controller.text = widget.initialText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == 'new') return _buildList(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      alignment: Alignment.topCenter,
      child: _isDeleted
          ? const SizedBox(width: double.infinity, height: 0)
          : Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: _buildList(context, isFeedback: true),
              ),
            ),
    );
  }

  Widget _buildCheckbox() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onToggleCompleted,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          border: widget.isCompleted
              ? Border.all(color: AppColors.completeTaskColor, width: 2)
              : Border.all(color: AppColors.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: widget.isCompleted
              ? AppColors.completeTaskColor
              : Colors.transparent,
        ),
        child: widget.isCompleted
            ? Icon(Icons.check, size: 16, color: AppColors.scaffoldBackground)
            : null,
      ),
    );
  }

  Widget _buildList(BuildContext context, {bool isFeedback = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.isDragging
                ? Colors.transparent
                : const Color(0xFFDDC584),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 64,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  if (widget.id == 'new') {
                    setState(() => _isEditing = true);
                    _focusNode.requestFocus();
                  } else {
                    _showActionMenu(context);
                  }
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: AbsorbPointer(
                    absorbing: !_isEditing,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: true,
                      readOnly: !_isEditing && widget.id != 'new',
                      autofocus: false,
                      cursorColor: AppColors.primaryColor,
                      showCursor: _isEditing || widget.id == 'new',
                      enableInteractiveSelection: _isEditing,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(left: 6),
                        isCollapsed: true,
                      ),
                      style: taskStyle.copyWith(
                        decoration: widget.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: widget.isCompleted
                            ? AppColors.completeTaskColor
                            : null,
                        decorationColor: AppColors.primaryColor.withAlpha(128),
                        decorationThickness: 1.5,
                      ),
                      strutStyle: StrutStyle(
                        forceStrutHeight: true,
                        fontSize: 18,
                        height: 1.2,
                      ),
                      onChanged: (val) {
                        if (widget.id != 'new' && val.isNotEmpty) {
                          widget.onTextChanged(val);
                        }
                      },
                      onSubmitted: (val) {
                        final trimmedVal = val.trim();
                        if (widget.id == 'new') {
                          if (trimmedVal.isNotEmpty) {
                            widget.onSubmitted?.call(trimmedVal);
                            _controller.clear();
                            _focusNode.requestFocus();
                          }
                        } else {
                          if (trimmedVal.isEmpty) {
                            _handleDelete();
                          } else {
                            _focusNode.unfocus();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.id != 'new') _buildCheckbox(),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 32, top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColorLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.primaryColor),
              title: Text('Edit task', style: taskStyle),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isEditing = true);
                _focusNode.requestFocus();
              },
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColorLight,
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFC20000)),
              title: Text(
                'Delete',
                style: taskStyle.copyWith(color: Color(0xFFC20000)),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
