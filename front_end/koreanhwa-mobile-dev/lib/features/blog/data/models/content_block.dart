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

