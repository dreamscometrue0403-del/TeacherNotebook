import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const TeacherNotebookApp());
}

class TeacherNotebookApp extends StatelessWidget {
  const TeacherNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teacher Notebook',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5963A5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7FF),
      ),
      home: const HomePage(),
    );
  }
}

// ------------------------------------------------------------
// HOME
// ------------------------------------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 45),
            const Text(
              'Teacher Notebook',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HomeCard(
                  icon: Icons.calculate_rounded,
                  title: 'Calculator',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalculatorPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 42),
                _HomeCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Books',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BooksPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F1F9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 7),
              color: Color(0x30000000),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 82,
              color: const Color(0xFF5963A5),
            ),
            const SizedBox(height: 35),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// BOOKS
// ------------------------------------------------------------

class Book {
  String name;

  Book(this.name);
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final List<Book> books = [];

  void createBook() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Book'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Book name',
              hintText: 'Example: Maths Notes',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                setState(() {
                  books.add(Book(name));
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Books',
          style: TextStyle(fontSize: 28),
        ),
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                'No books yet',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(
                      Icons.menu_book_rounded,
                      size: 42,
                      color: Color(0xFF5963A5),
                    ),
                    title: Text(
                      book.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotebookPage(
                            bookName: book.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createBook,
        backgroundColor: const Color(0xFF5963A5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Book',
          style: TextStyle(fontSize: 17),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ------------------------------------------------------------
// NOTEBOOK / DRAWING
// ------------------------------------------------------------

enum ToolType {
  pen,
  highlighter,
  eraser,
}

class DrawStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final ToolType tool;

  DrawStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });
}

class NotebookPage extends StatefulWidget {
  final String bookName;

  const NotebookPage({
    super.key,
    required this.bookName,
  });

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final List<DrawStroke> strokes = [];

  ToolType selectedTool = ToolType.pen;

  Color penColor = Colors.black;
  double penWidth = 4;

  List<Offset> currentPoints = [];

  bool isTwoFingerGesture = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookName),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: strokes.isEmpty
                ? null
                : () {
                    setState(() {
                      strokes.removeLast();
                    });
                  },
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                strokes.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,

            // Two fingers = don't draw.
            onScaleStart: (details) {
              if (details.pointerCount >= 2) {
                isTwoFingerGesture = true;
                currentPoints.clear();
              } else {
                isTwoFingerGesture = false;
                currentPoints = [details.localFocalPoint];
              }
            },

            onScaleUpdate: (details) {
              if (isTwoFingerGesture) {
                // Two finger movement can be used for page scrolling.
                return;
              }

              if (details.pointerCount == 1) {
                setState(() {
                  currentPoints.add(details.localFocalPoint);
                });
              }
            },

            onScaleEnd: (details) {
              if (isTwoFingerGesture) {
                isTwoFingerGesture = false;
                currentPoints.clear();
                return;
              }

              if (currentPoints.length < 2) {
                currentPoints.clear();
                return;
              }

              final points = List<Offset>.from(currentPoints);

              // Detect straight line if user holds/draws nearly straight.
              final simplified = _makeStraightIfNeeded(points);

              // Detect circle.
              final circle = _makeCircleIfNeeded(points);

              final finalPoints = circle ?? simplified;

              setState(() {
                strokes.add(
                  DrawStroke(
                    points: finalPoints,
                    color: selectedTool == ToolType.eraser
                        ? Colors.white
                        : penColor,
                    width: selectedTool == ToolType.highlighter
                        ? 18
                        : selectedTool == ToolType.eraser
                            ? 28
                            : penWidth,
                    tool: selectedTool,
                  ),
                );

                currentPoints.clear();
              });
            },

            child: CustomPaint(
              painter: NotebookPainter(
                strokes: strokes,
                currentPoints: currentPoints,
                currentColor: selectedTool == ToolType.eraser
                    ? Colors.white
                    : penColor,
                currentWidth: selectedTool == ToolType.highlighter
                    ? 18
                    : selectedTool == ToolType.eraser
                        ? 28
                        : penWidth,
                currentTool: selectedTool,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // TOOLBAR
          Positioned(
            left: 12,
            top: 15,
            child: _ToolBar(
              selectedTool: selectedTool,
              onToolChanged: (tool) {
                setState(() {
                  selectedTool = tool;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Offset> _makeStraightIfNeeded(List<Offset> points) {
    if (points.length < 10) {
      return points;
    }

    final first = points.first;
    final last = points.last;

    final dx = last.dx - first.dx;
    final dy = last.dy - first.dy;

    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance < 80) {
      return points;
    }

    double totalError = 0;

    for (final p in points) {
      final error = _distanceFromLine(
        p,
        first,
        last,
      );
      totalError += error;
    }

    final averageError = totalError / points.length;

    // Very straight stroke -> exact line.
    if (averageError < 18) {
      return [first, last];
    }

    return points;
  }

  double _distanceFromLine(
    Offset p,
    Offset a,
    Offset b,
  ) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;

    if (dx == 0 && dy == 0) {
      return (p - a).distance;
    }

    return ((dy * p.dx) -
            (dx * p.dy) +
            (b.dx * a.dy) -
            (b.dy * a.dx))
        .abs() /
        math.sqrt(dy * dy + dx * dx);
  }

  List<Offset>? _makeCircleIfNeeded(List<Offset> points) {
    if (points.length < 20) {
      return null;
    }

    final first = points.first;
    final last = points.last;

    final closingDistance = (first - last).distance;

    if (closingDistance > 60) {
      return null;
    }

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (final p in points) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }

    final width = maxX - minX;
    final height = maxY - minY;

    if (width < 50 || height < 50) {
      return null;
    }

    final ratio = width / height;

    if (ratio < 0.72 || ratio > 1.38) {
      return null;
    }

    final center = Offset(
      (minX + maxX) / 2,
      (minY + maxY) / 2,
    );

    final radius = (width + height) / 4;

    final result = <Offset>[];

    for (int i = 0; i <= 80; i++) {
      final angle = (math.pi * 2 * i) / 80;

      result.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }

    return result;
  }
}

// ------------------------------------------------------------
// TOOLBAR
// ------------------------------------------------------------

class _ToolBar extends StatelessWidget {
  final ToolType selectedTool;
  final ValueChanged<ToolType> onToolChanged;

  const _ToolBar({
    required this.selectedTool,
    required this.onToolChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            _toolButton(
              Icons.edit,
              ToolType.pen,
              'Pen',
            ),
            _toolButton(
              Icons.highlight,
              ToolType.highlighter,
              'Highlighter',
            ),
            _toolButton(
              Icons.cleaning_services,
              ToolType.eraser,
              'Eraser',
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(
    IconData icon,
    ToolType tool,
    String tooltip,
  ) {
    final selected = selectedTool == tool;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onToolChanged(tool),
        child: Container(
          width: 55,
          height: 55,
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFDDE1FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 28,
            color: const Color(0xFF5963A5),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// NOTEBOOK PAINTER
// ------------------------------------------------------------

class NotebookPainter extends CustomPainter {
  final List<DrawStroke> strokes;
  final List<Offset> currentPoints;

  final Color currentColor;
  final double currentWidth;
  final ToolType currentTool;

  NotebookPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
    required this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paper
    final paper = Paint()
      ..color = const Color(0xFFFFFEFF);

    canvas.drawRect(
      Offset.zero & size,
      paper,
    );

    // Notebook lines
    final linePaint = Paint()
      ..color = const Color(0xFFE2E2E8)
      ..strokeWidth = 1;

    const spacing = 42.0;

    for (double y = 30; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Saved strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // Current stroke
    if (currentPoints.length > 1) {
      final preview = DrawStroke(
        points: currentPoints,
        color: currentColor,
        width: currentWidth,
        tool: currentTool,
      );

      _drawStroke(canvas, preview);
    }
  }

  void _drawStroke(
    Canvas canvas,
    DrawStroke stroke,
  ) {
    if (stroke.points.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.tool == ToolType.highlighter) {
      paint.color = stroke.color.withOpacity(0.28);
      paint.strokeWidth = 22;
    }

    final path = Path();

    path.moveTo(
      stroke.points.first.dx,
      stroke.points.first.dy,
    );

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(
        stroke.points[i].dx,
        stroke.points[i].dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant NotebookPainter oldDelegate) {
    return true;
  }
}

// ------------------------------------------------------------
// CALCULATOR
// ------------------------------------------------------------

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String value = '0';

  void press(String text) {
    setState(() {
      if (text == 'C') {
        value = '0';
      } else if (text == '=') {
        try {
          value = _calculate(value);
        } catch (_) {
          value = 'Error';
        }
      } else {
        if (value == '0' || value == 'Error') {
          value = text;
        } else {
          value += text;
        }
      }
    });
  }

  String _calculate(String input) {
    input = input.replaceAll('×', '*');
    input = input.replaceAll('÷', '/');

    // Basic calculator evaluation.
    final match = RegExp(
      r'^(-?\d+(?:\.\d+)?)([+\-*/])(-?\d+(?:\.\d+)?)$',
    ).firstMatch(input);

    if (match == null) {
      return input;
    }

    final a = double.parse(match.group(1)!);
    final op = match.group(2)!;
    final b = double.parse(match.group(3)!);

    double result;

    switch (op) {
      case '+':
        result = a + b;
        break;
      case '-':
        result = a - b;
        break;
      case '*':
        result = a * b;
        break;
      case '/':
        result = a / b;
        break;
      default:
        result = 0;
    }

    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      'C',
      '÷',
      '×',
      '-',
      '7',
      '8',
      '9',
      '+',
      '4',
      '5',
      '6',
      '=',
      '1',
      '2',
      '3',
      '0',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(30),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: buttons.length,
            itemBuilder: (_, index) {
              final text = buttons[index];

              return ElevatedButton(
                onPressed: () => press(text),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 24),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
