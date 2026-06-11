import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? entryId;
  final String? initialPrompt;

  const EditorScreen({
    super.key,
    this.entryId,
    this.initialPrompt,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String? _selectedCategoryId;
  final List<String> _selectedTagIds = [];
  bool _isPrivate = true;
  int _wordCount = 0;
  
  // Auto-save simulation
  Timer? _debounceTimer;
  String _saveStatus = 'Draft saved'; // 'Saving...', 'Draft saved', 'Modified'
  JournalEntry? _existingEntry;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
    _titleController.addListener(_onTitleChanged);
    
    // Load entry if editing
    Future.microtask(() {
      if (widget.entryId != null) {
        final entriesState = ref.read(journalsProvider);
        entriesState.whenData((entries) {
          final entry = entries.firstWhere((e) => e.journalId == widget.entryId);
          setState(() {
            _existingEntry = entry;
            _titleController.text = entry.title;
            _contentController.text = entry.content;
            _selectedCategoryId = entry.categoryId;
            _selectedTagIds.clear();
            _selectedTagIds.addAll(entry.tagIds);
            _isPrivate = entry.isPrivate;
            _wordCount = entry.wordCount;
            _saveStatus = 'Draft loaded';
          });
        });
      } else if (widget.initialPrompt != null) {
        setState(() {
          _titleController.text = 'Reflection on: ${widget.initialPrompt}';
          _contentController.text = 'Today\'s prompt: "${widget.initialPrompt}"\n\n';
          _saveStatus = 'New draft';
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTitleChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    _markModified();
    _triggerAutoSave();
  }

  void _onContentChanged() {
    _updateWordCount();
    _markModified();
    _triggerAutoSave();
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      setState(() => _wordCount = 0);
    } else {
      setState(() => _wordCount = text.split(RegExp(r'\s+')).length);
    }
  }

  void _markModified() {
    if (_saveStatus == 'Draft saved' || _saveStatus == 'Draft loaded') {
      setState(() {
        _saveStatus = 'Unsaved changes';
      });
    }
  }

  void _triggerAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _simulateAutoSave();
    });
  }

  void _simulateAutoSave() {
    if (!mounted) return;
    setState(() {
      _saveStatus = 'Saving...';
    });
    
    // Simulate auto-save delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _saveStatus = 'Draft saved';
      });
    });
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$suffix');
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      );
    } else {
      // Append if no selection
      final cursor = _contentController.text.length;
      _contentController.text = '$text$prefix$suffix';
      _contentController.selection = TextSelection.collapsed(offset: cursor + prefix.length);
    }
  }

  void _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    final journalsNotifier = ref.read(journalsProvider.notifier);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (_existingEntry != null) {
        // Update existing entry
        final updated = _existingEntry!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
          tagIds: _selectedTagIds,
          isPrivate: _isPrivate,
          wordCount: _wordCount,
        );
        await journalsNotifier.updateEntry(updated);
      } else {
        // Create new entry
        await journalsNotifier.addEntry(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
          tagIds: _selectedTagIds,
          isPrivate: _isPrivate,
          entryDate: DateTime.now(),
        );
      }
      
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingEntry != null ? 'Entry updated successfully' : 'Entry created successfully'),
            backgroundColor: Colors.teal,
          ),
        );
        context.go('/journals'); // Return to list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);
    final tags = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryId == null ? 'New Journal Entry' : 'Edit Entry',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Auto-save indicator status
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _saveStatus == 'Saving...'
                        ? Icons.sync_rounded
                        : _saveStatus == 'Draft saved' || _saveStatus == 'Draft loaded'
                            ? Icons.check_circle_outline_rounded
                            : Icons.edit_note_rounded,
                    size: 16,
                    color: _saveStatus == 'Saving...'
                        ? theme.colorScheme.primary
                        : _saveStatus == 'Draft saved' || _saveStatus == 'Draft loaded'
                            ? Colors.green
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _saveStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: _saveStatus == 'Saving...'
                          ? theme.colorScheme.primary
                          : _saveStatus == 'Draft saved' || _saveStatus == 'Draft loaded'
                              ? Colors.green
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveEntry,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Editor Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.format_bold_rounded, size: 20),
                    onPressed: () => _insertFormatting('**', '**'),
                    tooltip: 'Bold',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_italic_rounded, size: 20),
                    onPressed: () => _insertFormatting('*', '*'),
                    tooltip: 'Italic',
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                    onPressed: () => _insertFormatting('\n- ', ''),
                    tooltip: 'Bullet List',
                  ),
                  const VerticalDivider(width: 20, thickness: 1, indent: 8, endIndent: 8),
                  
                  // Category Dropdown
                  DropdownButton<String?>(
                    value: _selectedCategoryId,
                    hint: const Text('Select Category', style: TextStyle(fontSize: 13)),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Uncategorized', style: TextStyle(fontSize: 13)),
                      ),
                      ...categories.map((c) => DropdownMenuItem(
                        value: c.categoryId,
                        child: Text(c.name, style: const TextStyle(fontSize: 13)),
                      )),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedCategoryId = val;
                      _markModified();
                      _triggerAutoSave();
                    }),
                  ),

                  const Spacer(),

                  // Lock / Privacy Toggle
                  Text(
                    _isPrivate ? 'Private' : 'Shared',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: !_isPrivate,
                    onChanged: (val) => setState(() {
                      _isPrivate = !val;
                      _markModified();
                      _triggerAutoSave();
                    }),
                    activeTrackColor: theme.colorScheme.secondary.withOpacity(0.2),
                    activeColor: theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),

            // Writing canvas
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextFormField(
                      controller: _titleController,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title your thoughts...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Title is required';
                        return null;
                      },
                    ),
                    const Divider(height: 24, thickness: 0.5),

                    // Content Canvas Input
                    TextFormField(
                      controller: _contentController,
                      maxLines: null,
                      minLines: 12,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Start writing your story here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Content is required';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Tags selector and Footer Stats bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tags Selection List
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 8),
                      Text('Tags:', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tags.map((t) {
                              final isSelected = _selectedTagIds.contains(t.tagId);
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: FilterChip(
                                  label: Text('#${t.name}', style: const TextStyle(fontSize: 11)),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTagIds.add(t.tagId);
                                      } else {
                                        _selectedTagIds.remove(t.tagId);
                                      }
                                      _markModified();
                                      _triggerAutoSave();
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Footer Word & Character counts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_wordCount words',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_contentController.text.length} characters',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
