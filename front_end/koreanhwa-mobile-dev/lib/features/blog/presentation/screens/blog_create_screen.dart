import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Model cho Block
class ContentBlock {
  String type;
  String content;
  Map<String, dynamic> style;

  ContentBlock({
    required this.type,
    this.content = '',
    Map<String, dynamic>? style,
  }) : style = style ?? {};
}

// Model cho Category
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({Key? key}) : super(key: key);

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  List<ContentBlock> blocks = [ContentBlock(type: 'text')];
  String selectedCategory = '';
  List<String> tags = [];
  File? featuredImage;
  bool isPreviewVisible = false;
  bool isSubmitting = false;

  final List<Category> categories = [
    Category(id: 'learning', name: 'Học tập'),
    Category(id: 'culture', name: 'Văn hóa'),
    Category(id: 'grammar', name: 'Ngữ pháp'),
    Category(id: 'vocabulary', name: 'Từ vựng'),
    Category(id: 'tips', name: 'Mẹo học'),
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickFeaturedImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        featuredImage = File(image.path);
      });
    }
  }

  Future<void> _pickBlockImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        blocks[index] = ContentBlock(
          type: 'image',
          content: image.path,
        );
      });
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      tags.removeAt(index);
    });
  }

  void _addBlock(String type) {
    setState(() {
      blocks.add(ContentBlock(type: type));
    });
  }

  void _removeBlock(int index) {
    if (blocks.length > 1) {
      setState(() {
        blocks.removeAt(index);
      });
    }
  }

  void _updateBlockContent(int index, String content) {
    setState(() {
      blocks[index].content = content;
    });
  }

  void _toggleBlockStyle(int index, String styleKey) {
    setState(() {
      final currentValue = blocks[index].style[styleKey] ?? false;
      blocks[index].style[styleKey] = !currentValue;
    });
  }

  void _setBlockAlignment(int index, String alignment) {
    setState(() {
      blocks[index].style['align'] = alignment;
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Log data (in real app, send to backend)
      print('Title: ${_titleController.text}');
      print('Category: $selectedCategory');
      print('Tags: $tags');
      print('Blocks: ${blocks.length}');

      setState(() {
        isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blog đã được lưu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.2),
                        Colors.purple.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.pink.withOpacity(0.2),
                        Colors.orange.withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          return _buildDesktopLayout();
                        } else {
                          return _buildMobileLayout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tạo Bài Blog Mới',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chia sẻ kiến thức và kinh nghiệm học tiếng Hàn của bạn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isPreviewVisible = !isPreviewVisible;
              });
            },
            icon: Icon(isPreviewVisible ? Icons.visibility_off : Icons.visibility),
            style: IconButton.styleFrom(
              backgroundColor: Colors.yellow.shade600,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildEditorSection(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: _buildPreviewSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildEditorSection(),
          if (isPreviewVisible) ...[
            const SizedBox(height: 16),
            _buildPreviewSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildEditorSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(),
                const SizedBox(height: 24),
                _buildCategoryField(),
                const SizedBox(height: 24),
                _buildBlocksEditor(),
                const SizedBox(height: 24),
                _buildTagsField(),
                const SizedBox(height: 24),
                _buildFeaturedImagePicker(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiêu đề',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Nhập tiêu đề bài blog...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tiêu đề';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory.isEmpty ? null : selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text('Chọn danh mục'),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategory = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn danh mục';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBlocksEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nội dung',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...blocks.asMap().entries.map((entry) {
          final index = entry.key;
          final block = entry.value;
          return _buildBlock(index, block);
        }).toList(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addBlock('text'),
                icon: const Icon(Icons.add),
                label: const Text('Thêm khối văn bản'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _addBlock('image'),
                icon: const Icon(Icons.image),
                label: const Text('Thêm hình ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade600,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlock(int index, ContentBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: block.type == 'text'
                ? _buildTextBlock(index, block)
                : _buildImageBlock(index, block),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => _removeBlock(index),
              icon: const Icon(Icons.close, size: 20),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlock(int index, ContentBlock block) {
    return Column(
      children: [
        Wrap(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () => _toggleBlockStyle(index, 'bold'),
              icon: const Icon(Icons.format_bold, size: 20),
              color: block.style['bold'] == true ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () => _toggleBlockStyle(index, 'italic'),
              icon: const Icon(Icons.format_italic, size: 20),
              color: block.style['italic'] == true ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () => _toggleBlockStyle(index, 'underline'),
              icon: const Icon(Icons.format_underlined, size: 20),
              color: block.style['underline'] == true ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () => _setBlockAlignment(index, 'left'),
              icon: const Icon(Icons.format_align_left, size: 20),
              color: block.style['align'] == 'left' ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () => _setBlockAlignment(index, 'center'),
              icon: const Icon(Icons.format_align_center, size: 20),
              color: block.style['align'] == 'center' ? Colors.blue : Colors.grey,
            ),
            IconButton(
              onPressed: () => _setBlockAlignment(index, 'right'),
              icon: const Icon(Icons.format_align_right, size: 20),
              color: block.style['align'] == 'right' ? Colors.blue : Colors.grey,
            ),
          ],
        ),
        TextField(
          controller: TextEditingController(text: block.content),
          onChanged: (value) => _updateBlockContent(index, value),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập văn bản...',
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontWeight: block.style['bold'] == true ? FontWeight.bold : FontWeight.normal,
            fontStyle: block.style['italic'] == true ? FontStyle.italic : FontStyle.normal,
            decoration: block.style['underline'] == true ? TextDecoration.underline : TextDecoration.none,
          ),
          textAlign: _getTextAlign(block.style['align']),
        ),
      ],
    );
  }

  TextAlign _getTextAlign(String? align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  Widget _buildImageBlock(int index, ContentBlock block) {
    return Column(
      children: [
        if (block.content.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(block.content),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _pickBlockImage(index),
          icon: const Icon(Icons.upload),
          label: Text(block.content.isEmpty ? 'Chọn hình ảnh' : 'Thay đổi hình ảnh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thẻ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            hintText: 'Nhập thẻ và nhấn Enter...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.local_offer),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeTag(entry.key),
                backgroundColor: Colors.blue.shade400,
                labelStyle: const TextStyle(color: Colors.white),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturedImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh nổi bật',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFeaturedImage,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, size: 32, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'Kéo và thả hoặc nhấn để tải ảnh lên',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    'PNG, JPG (tối đa 5MB)',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (featuredImage != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              featuredImage!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text('Hủy'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : _handleSubmit,
          icon: const Icon(Icons.save),
          label: Text(isSubmitting ? 'Đang lưu...' : 'Lưu bài viết'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade600,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xem trước',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isPreviewVisible)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (featuredImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            featuredImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _titleController.text.isEmpty ? 'Tiêu đề bài viết' : _titleController.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...blocks.map((block) {
                        if (block.type == 'text' && block.content.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              block.content,
                              style: TextStyle(
                                fontWeight: block.style['bold'] == true ? FontWeight.bold : FontWeight.normal,
                                fontStyle: block.style['italic'] == true ? FontStyle.italic : FontStyle.normal,
                                decoration: block.style['underline'] == true ? TextDecoration.underline : TextDecoration.none,
                              ),
                              textAlign: _getTextAlign(block.style['align']),
                            ),
                          );
                        } else if (block.type == 'image' && block.content.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(block.content),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            return Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 10)),
                              backgroundColor: Colors.black,
                              labelStyle: const TextStyle(color: Colors.white),
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Danh mục: ${categories.firstWhere((cat) => cat.id == selectedCategory, orElse: () => Category(id: '', name: 'Chưa chọn')).name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.description, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Đăng bởi bạn',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_off, size: 32, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Bật xem trước để thấy nội dung bài viết',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      textAlign: TextAlign.center,
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