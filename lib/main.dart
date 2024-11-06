import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
  });
  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _icons;
  int? _draggingIndex;
  int? _hoveringIndex;

  List<double> _scales = [];

  @override
  void initState() {
    super.initState();
    _icons = List.from(widget.items); 
    _scales = List.filled(_icons.length, 1.0);
  }

  void _applyMagnificationEffect(int hoverIndex) {
    setState(() {
      for (int i = 0; i < _scales.length; i++) {
        final distance = (i - hoverIndex).abs();
        _scales[i] = distance == 0 ? 1.3 : (distance == 1 ? 1.2 : 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_icons.length, (index) {
          final iconData = _icons[index];
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: DragTarget<IconData>(
              onWillAccept: (data) {
                _applyMagnificationEffect(index);
                setState(() {
                  _hoveringIndex = index;
                });
                return true;
              },
              onLeave: (_) {
                setState(() {
                  _hoveringIndex = null;
                  _scales = List.filled(_icons.length, 1.0);
                });
              },
              onAccept: (data) {
                setState(() {
                  final draggedIcon = _icons.removeAt(_draggingIndex!);
                  _icons.insert(index, draggedIcon);
                  _draggingIndex = null;
                  _hoveringIndex = null;
                  _scales = List.filled(_icons.length, 1.0);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Draggable<IconData>(
                  data: iconData,
                  onDragStarted: () {
                    setState(() {
                      _draggingIndex = index;
                    });
                  },
                  onDragEnd: (_) {
                    setState(() {
                      _draggingIndex = null;
                      _hoveringIndex = null;
                      _scales = List.filled(_icons.length, 1.0);
                    });
                  },
                  feedback: Material(
                    color: Colors.transparent,
                    child: Transform.scale(
                      scale: 1.4,
                      child: DockItem(iconData: iconData, isDragging: true),
                    ),
                  ),
                  childWhenDragging: SizedBox(
                    width: 56,
                    height: 56,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: DockItem(
                      key: ValueKey(iconData),
                      iconData: iconData,
                      scale: _scales[index],
                      isHovered: _hoveringIndex == index,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({
    required this.iconData,
    this.scale = 1.0,
    this.isDragging = false,
    this.isHovered = false,
    super.key,
  });

  final IconData iconData;

  final double scale;

  final bool isDragging;

  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56 * scale,
      height: 56 * scale,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.primaries[iconData.hashCode % Colors.primaries.length],
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Icon(iconData, color: Colors.white, size: 24 * scale),
    );
  }
}
