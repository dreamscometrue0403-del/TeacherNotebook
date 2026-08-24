import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const TeacherNotebookApp());
}

// ============================================================
// APP
// ============================================================

class TeacherNotebookApp extends StatelessWidget {
  const TeacherNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Teacher Notebook',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F7FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF555D9C),
        ),
        fontFamily: 'sans',
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

enum ToolType {
  pen,
  highlighter,
  eraser,
}

enum StrokeShape {
  free,
  line,
  circle,
}

class DrawingPoint {
  final double x;
  final double y;

  DrawingPoint(this.x, this.y);

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    return DrawingPoint(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }

  Offset get offset => Offset(x, y);
}

class DrawingStroke {
  final List<DrawingPoint> points;
  final int color;
  final double width;
  final ToolType tool;
  final StrokeShape shape;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
    this.shape = StrokeShape.free,
  });

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => p.toJson()).toList(),
      'color': color,
      'width': width,
      'tool': tool.name,
      'shape': shape.name,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as List)
        .map(
          (p) => DrawingPoint.fromJson(
            Map<String, dynamic>.from(p),
          ),
        )
        .toList();

    return DrawingStroke(
      points: points,
      color: json['color'] as int,
      width: (json['width'] as num).toDouble(),
      tool: ToolType.values.firstWhere(
        (e) => e.name == json['tool'],
        orElse: () => ToolType.pen,
      ),
      shape: StrokeShape.values.firstWhere(
        (e) => e.name == json['shape'],
        orElse: () => StrokeShape.free,
      ),
    );
  }
}

class NotebookPage {
  final List<DrawingStroke> strokes;

  NotebookPage({
    List<DrawingStroke>? strokes,
  }) : strokes = strokes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'strokes': strokes.map((s) => s.toJson()).toList(),
    };
  }

  factory NotebookPage.fromJson(Map<String, dynamic> json) {
    return NotebookPage(
      strokes: (json['strokes'] as List? ?? [])
          .map(
            (s) => DrawingStroke.fromJson(
              Map<String, dynamic>.from(s),
            ),
          )
          .toList(),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            const Text(
              'Teacher Notebook',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Color(0xFF20202A),
              ),
            ),

            const SizedBox(height: 48),

            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 45),

                  Expanded(
                    child: _HomeCard(
                      icon: Icons.calculate_rounded,
                      title: 'Calculator',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalculatorScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 42),

                  Expanded(
                    child: _HomeCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Books',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BooksScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 45),
                ],
              ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          height: 275,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F1F9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 90,
                color: const Color(0xFF565E9E),
              ),
              const SizedBox(height: 35),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOOKS
// ============================================================

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<String> books = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      books = prefs.getStringList('books') ?? [];
    });
  }

  Future<void> createBook() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Book'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Book name',
              hintText: 'Example: Accounts',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    books.add(name);

    await prefs.setStringList('books', books);

    await saveBookPages(name, [
      NotebookPage(),
    ]);

    setState(() {});
  }

  Future<void> deleteBook(String name) async {
    final prefs = await SharedPreferences.getInstance();

    books.remove(name);

    await prefs.setStringList('books', books);
    await prefs.remove('book_$name');

    setState(() {});
  }

  Future<void> saveBookPages(
    String name,
    List<NotebookPage> pages,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      pages.map((p) => p.toJson()).toList(),
    );

    await prefs.setString('book_$name', encoded);
  }

  Future<List<NotebookPage>> loadBookPages(String name) async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('book_$name');

    if (data == null) {
      return [NotebookPage()];
    }

    final list = jsonDecode(data) as List;

    return list
        .map(
          (e) => NotebookPage.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  void openBook(String name) async {
    final pages = await loadBookPages(name);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotebookScreen(
          bookName: name,
          initialPages: pages,
          onSave: (updatedPages) async {
            await saveBookPages(name, updatedPages);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 34,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Books',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: books.isEmpty
          ? Center(
              child: _CreateBookButton(
                onTap: createBook,
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(25),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        leading: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF555D9C),
                          size: 40,
                        ),
                        title: Text(
                          book,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => openBook(book),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          onPressed: () => deleteBook(book),
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _CreateBookButton(
                      onTap: createBook,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CreateBookButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateBookButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add),
      label: const Text(
        'Create Book',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF565E9E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
}

// ============================================================
// NOTEBOOK
// ============================================================

class NotebookScreen extends StatefulWidget {
  final String bookName;
  final List<NotebookPage> initialPages;
  final Future<void> Function(List<NotebookPage>) onSave;

  const NotebookScreen({
    super.key,
    required this.bookName,
    required this.initialPages,
    required this.onSave,
  });

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  late List<NotebookPage> pages;

  int currentPage = 0;

  ToolType selectedTool = ToolType.pen;

  Color selectedColor = Colors.black;

  double strokeWidth = 4;

  DrawingStroke? currentStroke;

  final List<List<DrawingStroke>> undoStack = [];
  final List<List<DrawingStroke>> redoStack = [];

  int activePointers = 0;

  Offset? twoFingerStart;

  bool twoFingerGesture = false;

  DateTime? strokeStart;

  @override
  void initState() {
    super.initState();

    pages = widget.initialPages.isEmpty
        ? [NotebookPage()]
        : widget.initialPages;
  }

  NotebookPage get page => pages[currentPage];

  Future<void> save() async {
    await widget.onSave(pages);
  }

  void saveUndoState() {
    undoStack.add(
      page.strokes
          .map(
            (stroke) => DrawingStroke(
              points: List.from(stroke.points),
              color: stroke.color,
              width: stroke.width,
              tool: stroke.tool,
              shape: stroke.shape,
            ),
          )
          .toList(),
    );

    if (undoStack.length > 50) {
      undoStack.removeAt(0);
    }

    redoStack.clear();
  }

  void undo() {
    if (undoStack.isEmpty) return;

    redoStack.add(
      page.strokes
          .map(
            (stroke) => DrawingStroke(
              points: List.from(stroke.points),
              color: stroke.color,
              width: stroke.width,
              tool: stroke.tool,
              shape: stroke.shape,
            ),
          )
          .toList(),
    );

    setState(() {
      page.strokes
        ..clear()
        ..addAll(undoStack.removeLast());
    });

    save();
  }

  void redo() {
    if (redoStack.isEmpty) return;

    undoStack.add(
      page.strokes
          .map(
            (stroke) => DrawingStroke(
              points: List.from(stroke.points),
              color: stroke.color,
              width: stroke.width,
              tool: stroke.tool,
              shape: stroke.shape,
            ),
          )
          .toList(),
    );

    setState(() {
      page.strokes
        ..clear()
        ..addAll(redoStack.removeLast());
    });

    save();
  }

  void onPointerDown(PointerDownEvent event) {
    activePointers++;

    if (activePointers >= 2) {
      twoFingerGesture = true;
      twoFingerStart = event.position;

      currentStroke = null;

      setState(() {});
      return;
    }

    if (selectedTool == ToolType.eraser) {
      eraseAt(event.localPosition);
      return;
    }

    strokeStart = DateTime.now();

    currentStroke = DrawingStroke(
      points: [
        DrawingPoint(
          event.localPosition.dx,
          event.localPosition.dy,
        ),
      ],
      color: selectedColor.value,
      width: strokeWidth,
      tool: selectedTool,
    );

    setState(() {});
  }

  void onPointerMove(PointerMoveEvent event) {
    if (activePointers >= 2 || twoFingerGesture) {
      return;
    }

    if (currentStroke == null) return;

    currentStroke!.points.add(
      DrawingPoint(
        event.localPosition.dx,
        event.localPosition.dy,
      ),
    );

    setState(() {});
  }

  void onPointerUp(PointerUpEvent event) {
    activePointers--;

    if (twoFingerGesture) {
      if (activePointers <= 0) {
        final start = twoFingerStart;

        if (start != null) {
          final dy = event.position.dy - start.dy;

          if (dy < -80) {
            nextPage();
          } else if (dy > 80) {
            previousPage();
          }
        }

        twoFingerStart = null;
        twoFingerGesture = false;
        activePointers = 0;
      }

      return;
    }

    finishStroke();
  }

  void onPointerCancel(PointerCancelEvent event) {
    activePointers = math.max(0, activePointers - 1);

    if (activePointers == 0) {
      currentStroke = null;
      twoFingerGesture = false;
      twoFingerStart = null;
      setState(() {});
    }
  }

  void finishStroke() {
    if (currentStroke == null) return;

    final stroke = currentStroke!;

    currentStroke = null;

    if (stroke.points.length >= 2) {
      saveUndoState();

      final duration = DateTime.now().difference(
        strokeStart ?? DateTime.now(),
      );

      final corrected = recognizeShape(
        stroke,
        duration,
      );

      setState(() {
        page.strokes.add(corrected);
      });

      save();
    }

    strokeStart = null;

    setState(() {});
  }

  DrawingStroke recognizeShape(
    DrawingStroke stroke,
    Duration duration,
  ) {
    if (stroke.tool != ToolType.pen) {
      return stroke;
    }

    if (stroke.points.length < 8) {
      return stroke;
    }

    // Hold for around half a second to trigger shape correction.
    if (duration.inMilliseconds < 450) {
      return stroke;
    }

    final first = stroke.points.first.offset;
    final last = stroke.points.last.offset;

    final dx = last.dx - first.dx;
    final dy = last.dy - first.dy;

    final distance = math.sqrt(
      dx * dx + dy * dy,
    );

    if (distance < 40) {
      return stroke;
    }

    // ----------------------------------------------------------
    // STRAIGHT LINE
    // ----------------------------------------------------------

    double maxLineError = 0;

    for (final point in stroke.points) {
      final error = distanceToLine(
        point.offset,
        first,
        last,
      );

      maxLineError = math.max(
        maxLineError,
        error,
      );
    }

    if (maxLineError < 25) {
      return DrawingStroke(
        points: [
          DrawingPoint(
            first.dx,
            first.dy,
          ),
          DrawingPoint(
            last.dx,
            last.dy,
          ),
        ],
        color: stroke.color,
        width: stroke.width,
        tool: stroke.tool,
        shape: StrokeShape.line,
      );
    }

    // ----------------------------------------------------------
    // CIRCLE
    // ----------------------------------------------------------

    final center = Offset(
      (first.dx + last.dx) / 2,
      (first.dy + last.dy) / 2,
    );

    final radii = <double>[];

    for (final point in stroke.points) {
      radii.add(
        (point.offset - center).distance,
      );
    }

    final averageRadius =
        radii.reduce((a, b) => a + b) / radii.length;

    if (averageRadius < 35) {
      return stroke;
    }

    double radiusError = 0;

    for (final radius in radii) {
      radiusError = math.max(
        radiusError,
        (radius - averageRadius).abs(),
      );
    }

    final closedDistance = (last - first).distance;

    if (radiusError < 30 && closedDistance < 100) {
      return DrawingStroke(
        points: [
          DrawingPoint(
            center.dx,
            center.dy,
          ),
          DrawingPoint(
            averageRadius,
            0,
          ),
        ],
        color: stroke.color,
        width: stroke.width,
        tool: stroke.tool,
        shape: StrokeShape.circle,
      );
    }

    return stroke;
  }

  double distanceToLine(
    Offset p,
    Offset a,
    Offset b,
  ) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;

    if (dx == 0 && dy == 0) {
      return (p - a).distance;
    }

    final t = ((p.dx - a.dx) * dx +
            (p.dy - a.dy) * dy) /
        (dx * dx + dy * dy);

    final clamped = t.clamp(0.0, 1.0);

    final projection = Offset(
      a.dx + clamped * dx,
      a.dy + clamped * dy,
    );

    return (p - projection).distance;
  }

  void eraseAt(Offset position) {
    if (page.strokes.isEmpty) return;

    saveUndoState();

    page.strokes.removeWhere(
      (stroke) {
        for (final point in stroke.points) {
          if ((point.offset - position).distance <
              stroke.width * 3 + 25) {
            return true;
          }
        }

        return false;
      },
    );

    setState(() {});

    save();
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      setState(() {
        currentPage++;
      });
    } else {
      setState(() {
        pages.add(NotebookPage());
        currentPage++;
      });

      save();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  void addPage() {
    setState(() {
      pages.add(NotebookPage());
      currentPage = pages.length - 1;
    });

    save();
  }

  void clearPage() {
    if (page.strokes.isEmpty) return;

    saveUndoState();

    setState(() {
      page.strokes.clear();
    });

    save();
  }

  void showColorPicker() {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });

                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: color,
                    child: selectedColor.value == color.value
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void showSizePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Stroke Size',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Slider(
                    min: 1,
                    max: 25,
                    value: strokeWidth,
                    onChanged: (value) {
                      setModalState(() {});
                      setState(() {
                        strokeWidth = value;
                      });
                    },
                  ),

                  Text(
                    '${strokeWidth.toStringAsFixed(1)} px',
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () async {
            await save();

            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.bookName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: redo,
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: addPage,
          ),
        ],
      ),
      body: Column(
        children: [
          _toolBar(),

          Expanded(
            child: Container(
              color: Colors.white,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: onPointerDown,
                onPointerMove: onPointerMove,
                onPointerUp: onPointerUp,
                onPointerCancel: onPointerCancel,
                child: CustomPaint(
                  painter: NotebookPainter(
                    strokes: page.strokes,
                    currentStroke: currentStroke,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),

          _bottomBar(),
        ],
      ),
    );
  }

  Widget _toolBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 8),

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

            const VerticalDivider(
              width: 20,
              indent: 12,
              endIndent: 12,
            ),

            IconButton(
              tooltip: 'Color',
              onPressed: selectedTool == ToolType.eraser
                  ? null
                  : showColorPicker,
              icon: CircleAvatar(
                radius: 13,
                backgroundColor: selectedColor,
              ),
            ),

            IconButton(
              tooltip: 'Size',
              onPressed: showSizePicker,
              icon: const Icon(
                Icons.line_weight,
              ),
            ),

            IconButton(
              tooltip: 'Clear page',
              onPressed: clearPage,
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),

            const SizedBox(width: 8),
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: () {
          setState(() {
            selectedTool = tool;
          });
        },
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? const Color(0xFFE0E3FF)
              : Colors.transparent,
        ),
        icon: Icon(
          icon,
          size: 28,
          color: selected
              ? const Color(0xFF555D9C)
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      height: 48,
      color: Colors.white,
      child: Center(
        child: Text(
          'Page ${currentPage + 1} / ${pages.length}   •   Two fingers ↑ ↓ to change page',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTEBOOK PAINTER
// ============================================================

class NotebookPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  NotebookPainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final background = Paint()
      ..color = Colors.white;

    canvas.drawRect(
      Offset.zero & size,
      background,
    );

    drawPaperLines(
      canvas,
      size,
    );

    for (final stroke in strokes) {
      drawStroke(
        canvas,
        stroke,
      );
    }

    if (currentStroke != null) {
      drawStroke(
        canvas,
        currentStroke!,
      );
    }
  }

  void drawPaperLines(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFE3E5EE)
      ..strokeWidth = 1;

    const spacing = 42.0;

    for (
      double y = spacing;
      y < size.height;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void drawStroke(
    Canvas canvas,
    DrawingStroke stroke,
  ) {
    if (stroke.points.isEmpty) return;

    final opacity =
        stroke.tool == ToolType.highlighter
            ? 0.30
            : 1.0;

    final paint = Paint()
      ..color = Color(stroke.color).withOpacity(opacity)
      ..strokeWidth = stroke.tool == ToolType.highlighter
          ? stroke.width * 3
          : stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.shape == StrokeShape.line &&
        stroke.points.length >= 2) {
      canvas.drawLine(
        stroke.points.first.offset,
        stroke.points.last.offset,
        paint,
      );

      return;
    }

    if (stroke.shape == StrokeShape.circle &&
        stroke.points.length >= 2) {
      final center = stroke.points.first.offset;
      final radius = stroke.points[1].x;

      canvas.drawCircle(
        center,
        radius,
        paint,
      );

      return;
    }

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first.offset,
        paint.strokeWidth / 2,
        Paint()
          ..color = Color(stroke.color).withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );

      return;
    }

    final path = Path();

    path.moveTo(
      stroke.points.first.x,
      stroke.points.first.y,
    );

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(
        stroke.points[i].x,
        stroke.points[i].y,
      );
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant NotebookPainter oldDelegate,
  ) {
    return true;
  }
}

// ============================================================
// CALCULATOR
// ============================================================

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState
    extends State<CalculatorScreen> {
  String display = '0';

  void press(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        return;
      }

      if (value == '=') {
        try {
          display = calculate(display);
        } catch (_) {
          display = 'Error';
        }

        return;
      }

      if (display == '0' && value != '.') {
        display = value;
      } else {
        display += value;
      }
    });
  }

  String calculate(String expression) {
    expression = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    final tokens = RegExp(
      r'(\d+(?:\.\d+)?)|([+\-*/])',
    ).allMatches(expression);

    final values = <double>[];
    final operators = <String>[];

    for (final match in tokens) {
      final text = match.group(0)!;

      if (double.tryParse(text) != null) {
        values.add(double.parse(text));
      } else {
        operators.add(text);
      }
    }

    if (values.isEmpty) {
      return '0';
    }

    double result = values.first;

    for (int i = 0; i < operators.length; i++) {
      final op = operators[i];

      if (i + 1 >= values.length) break;

      final next = values[i + 1];

      switch (op) {
        case '+':
          result += next;
          break;
        case '-':
          result -= next;
          break;
        case '*':
          result *= next;
          break;
        case '/':
          result /= next;
          break;
      }
    }

    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ['C', '÷', '×', '−'],
      ['7', '8', '9', '+'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '='],
      ['0', '.', '', ''],
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
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          for (final row in buttons)
            Expanded(
              child: Row(
                children: [
                  for (final button in row)
                    Expanded(
                      child: button.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                onPressed: () =>
                                    press(button),
                                child: Text(
                                  button,
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
