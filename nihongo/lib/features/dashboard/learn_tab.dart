import 'package:flutter/material.dart';

import 'learn/library/library_view.dart';
import 'learn/notebook/my_notebook_view.dart';
import 'learn/widgets/learn_header.dart';
import 'learn/widgets/learn_tab_bar.dart';
import 'learning_topic.dart';

/// Màn hình chính của phần "Học tập":
/// - Header: "Học tập"
/// - Thanh tab bar trên cùng chỉ gồm 2 mục: "Sổ tay của tôi" & "Thư viện"
/// - Nội dung chuyển đổi mượt mà giữa Sổ tay của tôi và Thư viện.
class LearnTab extends StatefulWidget {
  const LearnTab({
    super.key,
    required this.onTopicTap,
    this.initialTabIndex = 0,
  });

  final ValueChanged<LearningTopic> onTopicTap;
  final int initialTabIndex;

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(covariant LearnTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      _selectedTab = widget.initialTabIndex;
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tiêu đề và nút Nâng cấp
          const LearnHeader(),
          const SizedBox(height: 14),

          // Thanh tab bar chọn Sổ tay / Thư viện
          LearnTopTabBar(
            selectedIndex: _selectedTab,
            onTabChanged: _onTabChanged,
          ),
          const SizedBox(height: 16),

          // Nội dung hiển thị theo tab
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedTab == 0
                  ? const MyNotebookView(
                      key: ValueKey('my_notebook_view'),
                    )
                  : LibraryView(
                      key: const ValueKey('library_view'),
                      onTopicTap: widget.onTopicTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
