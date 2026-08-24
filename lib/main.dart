import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const TeacherNotebookApp());

class TeacherNotebookApp extends StatelessWidget {
  const TeacherNotebookApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Teacher Notebook',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF9F7FC)),
    home: const HomePage(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(children: [
          const Text('Teacher Notebook', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 48),
          Expanded(child: Row(children: [
            Expanded(child: _HomeCard(icon: Icons.calculate_rounded, title: 'Calculator', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculatorPage())))),
            const SizedBox(width: 18),
            Expanded(child: _HomeCard(icon: Icons.menu_book_rounded, title: 'Books', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BooksPage())))),
          ])),
        ]),
      ),
    ),
  );
}

class _HomeCard extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const _HomeCard({required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    elevation: 5, shadowColor: Colors.black26,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: InkWell(
      borderRadius: BorderRadius.circular(22), onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 72, color: const Color(0xFF5960A0)),
        const SizedBox(height: 28),
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      ])),
    ),
  );
}

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Books', style: TextStyle(fontSize: 26))),
    body: Center(child: FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF5960A0), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), shape: const StadiumBorder()),
      icon: const Icon(Icons.add), label: const Text('Create Book', style: TextStyle(fontSize: 19)),
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotebookPage())),
    )),
  );
}

class CalculatorPage extends StatefulWidget { const CalculatorPage({super.key}); @override State<CalculatorPage> createState() => _CalculatorPageState(); }
class _CalculatorPageState extends State<CalculatorPage> {
  String display='0'; String? op; double? first;
  void press(String v) => setState(() {
    if (v=='C') { display='0'; op=null; first=null; return; }
    if ('+-×÷'.contains(v)) { first=double.tryParse(display)??0; op=v; display='0'; return; }
    if (v=='=') { final b=double.tryParse(display)??0, a=first??0; double r=b; switch(op){case '+':r=a+b;break;case '-':r=a-b;break;case '×':r=a*b;break;case '÷':r=b==0?0:a/b;break;} display=r.toString().replaceAll(RegExp(r'\.0$'),''); op=null; first=null; return; }
    if(v=='.'){if(!display.contains('.'))display+='.';}else{display=display=='0'?v:display+v;}
  });
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calculator')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Container(alignment: Alignment.centerRight,padding: const EdgeInsets.all(22),child: Text(display,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:44,fontWeight:FontWeight.w700))),
      Expanded(child: GridView.count(crossAxisCount:4,mainAxisSpacing:10,crossAxisSpacing:10,children:['C','÷','×','-','7','8','9','+','4','5','6','=','1','2','3','.','0'].map((k)=>FilledButton(onPressed:()=>press(k),style:FilledButton.styleFrom(backgroundColor:const Color(0xFF5960A0),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16))),child:Text(k,style:const TextStyle(fontSize:24)))).toList())),
    ])),
  );
}

enum PenMode { pen, highlighter, eraser, line, circle }
class Stroke {
  final List<Offset> points; final Color color; final double width; final PenMode mode;
  Stroke({required this.points,required this.color,required this.width,required this.mode});
}

class NotebookPage extends StatefulWidget { const NotebookPage({super.key}); @override State<NotebookPage> createState()=>_NotebookPageState(); }
class _NotebookPageState extends State<NotebookPage> {
  final List<Stroke> strokes=[]; final List<Stroke> redo=[];
  PenMode mode=PenMode.pen; Color color=const Color(0xFF43A84B); double width=4;
  int pointers=0; Offset? twoLast; double pageOffset=0; Stroke? current; Timer? holdTimer; bool toolbar=true;
  final colors=const [Color(0xFF202020),Color(0xFF43A84B),Color(0xFF3F51B5),Color(0xFFE53935),Color(0xFFFF9800),Color(0xFF9C27B0)];

  void down(PointerDownEvent e){
    pointers++;
    if(pointers>=2){ holdTimer?.cancel(); current=null; twoLast=e.localPosition; setState((){}); return; }
    if(pointers!=1)return;
    current=Stroke(points:[e.localPosition+Offset(0,pageOffset)],color:color,width:width,mode:mode);
    strokes.add(current!); redo.clear();
    holdTimer=Timer(const Duration(milliseconds:520),(){
      if(pointers==1 && current!=null && current!.points.length>=8) _recognize(current!);
    });
    setState((){});
  }

  void move(PointerMoveEvent e){
    if(pointers>=2){
      final p=twoLast;
      if(p!=null){final dy=e.localPosition.dy-p.dy; setState(()=>pageOffset=(pageOffset-dy).clamp(0.0,1800.0).toDouble());}
      twoLast=e.localPosition; return;
    }
    if(pointers!=1||current==null)return;
    current!.points.add(e.localPosition+Offset(0,pageOffset));
    holdTimer?.cancel();
    holdTimer=Timer(const Duration(milliseconds:520),(){if(pointers==1&&current!=null)_recognize(current!);});
    setState((){});
  }

  void up(PointerUpEvent e){
    pointers=math.max(0,pointers-1);
    if(pointers==0){holdTimer?.cancel();twoLast=null; if(current!=null)_recognize(current!); current=null; setState((){});}
  }
  void cancel(PointerCancelEvent e){pointers=math.max(0,pointers-1);if(pointers==0){holdTimer?.cancel();current=null;twoLast=null;setState((){});}}

  void _recognize(Stroke s){
    if(s.mode!=PenMode.pen && s.mode!=PenMode.highlighter)return;
    if(s.points.length<8)return;
    final a=s.points.first,b=s.points.last;
    final straight=_straightness(s.points,a,b);
    if((s.mode==PenMode.pen||s.mode==PenMode.highlighter)&&straight>0.985 && (b-a).distance>80){
      final snap=_snap(a,b); final i=strokes.indexOf(s); if(i>=0)strokes[i]=Stroke(points:[snap.$1,snap.$2],color:s.color,width:s.width,mode:PenMode.line); setState((){}); return;
    }
    final fit=_circle(s.points);
    if(fit!=null && fit.$2>0.70 && _closed(s.points)){
      final pts=<Offset>[];for(int i=0;i<=80;i++){final ang=2*math.pi*i/80;pts.add(fit.$1+Offset(math.cos(ang)*fit.$3,math.sin(ang)*fit.$3));}
      final i=strokes.indexOf(s);if(i>=0)strokes[i]=Stroke(points:pts,color:s.color,width:s.width,mode:PenMode.circle);setState((){});
    }
  }
  double _straightness(List<Offset> ps,Offset a,Offset b){final dx=b.dx-a.dx,dy=b.dy-a.dy,len=math.sqrt(dx*dx+dy*dy);if(len==0)return 0;double total=0;for(final p in ps){final cross=((p.dx-a.dx)*dy-(p.dy-a.dy)*dx).abs();total+=cross/len;}final avg=total/ps.length;return (1-avg/30).clamp(0.0,1.0).toDouble();}
  (Offset,Offset)_snap(Offset a,Offset b){final dx=b.dx-a.dx,dy=b.dy-a.dy,ang=math.atan2(dy,dx),step=math.pi/12,sa=(ang/step).round()*step,len=math.sqrt(dx*dx+dy*dy);return(a,a+Offset(math.cos(sa)*len,math.sin(sa)*len));}
  bool _closed(List<Offset> p){if(p.length<8)return false;double path=0;for(int i=1;i<p.length;i++)path+=(p[i]-p[i-1]).distance;return (p.first-p.last).distance<path*.25;}
  (Offset,double,double)? _circle(List<Offset> p){double minX=p.first.dx,maxX=p.first.dx,minY=p.first.dy,maxY=p.first.dy;for(final x in p){minX=math.min(minX,x.dx);maxX=math.max(maxX,x.dx);minY=math.min(minY,x.dy);maxY=math.max(maxY,x.dy);}final c=Offset((minX+maxX)/2,(minY+maxY)/2),r=((maxX-minX)+(maxY-minY))/4;if(r<35)return null;double err=0;for(final x in p)err+=((x-c).distance-r).abs()/r;final score=(1-err/p.length).clamp(0.0,1.0).toDouble();return(c,score,r);}
  void undo(){if(strokes.isNotEmpty)setState(()=>redo.add(strokes.removeLast()));}
  void redoIt(){if(redo.isNotEmpty)setState(()=>strokes.add(redo.removeLast()));}
  void clear(){setState(()=>{strokes.clear();redo.clear();});}

  @override void dispose(){holdTimer?.cancel();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.white,body:SafeArea(child:Column(children:[
    Container(height:66,decoration:const BoxDecoration(color:Colors.white,border:Border(bottom:BorderSide(color:Color(0xFFE3E3E3)))),child:Row(children:[IconButton(icon:const Icon(Icons.arrow_back,size:30),onPressed:()=>Navigator.pop(context)),const SizedBox(width:8),const Expanded(child:Text('My Notebook   •   1/1',style:TextStyle(fontSize:18,fontWeight:FontWeight.w600))),IconButton(onPressed:undo,icon:const Icon(Icons.undo,size:28)),IconButton(onPressed:redoIt,icon:const Icon(Icons.redo,size:28))])),
    Expanded(child:Stack(children:[
      Positioned.fill(child:Listener(behavior:HitTestBehavior.opaque,onPointerDown:down,onPointerMove:move,onPointerUp:up,onPointerCancel:cancel,child:CustomPaint(painter:NotebookPainter(strokes:strokes,pageOffset:pageOffset)))),
      if(toolbar)Positioned(left:10,top:12,child:Material(elevation:5,borderRadius:BorderRadius.circular(20),color:Colors.white,child:Padding(padding:const EdgeInsets.symmetric(vertical:10,horizontal:7),child:Column(children:[
        tool(Icons.edit,PenMode.pen,'Pen'),tool(Icons.highlight,PenMode.highlighter,'Highlighter'),tool(Icons.horizontal_rule,PenMode.line,'Line'),tool(Icons.circle_outlined,PenMode.circle,'Circle'),tool(Icons.auto_fix_normal,PenMode.eraser,'Eraser'),const SizedBox(height:8),Container(height:1,width:42,color:Color(0xFFE0E0E0)),const SizedBox(height:8),...colors.map((c)=>GestureDetector(onTap:()=>setState(()=>color=c),child:Container(margin:const EdgeInsets.symmetric(vertical:4),width:28,height:28,decoration:BoxDecoration(color:c,shape:BoxShape.circle,border:Border.all(color:color==c?Colors.black:Colors.transparent,width:2))))),const SizedBox(height:6),IconButton(onPressed:clear,icon:const Icon(Icons.delete_outline))])))),
      Positioned(right:16,bottom:16,child:FloatingActionButton.small(backgroundColor:Colors.white,onPressed:()=>setState(()=>toolbar=!toolbar),child:Icon(toolbar?Icons.close:Icons.edit,color:const Color(0xFF454545)))),
    ])),
  ])));

  Widget tool(IconData icon,PenMode m,String label){final selected=mode==m;return Tooltip(message:label,child:Padding(padding:const EdgeInsets.symmetric(vertical:3),child:InkWell(borderRadius:BorderRadius.circular(14),onTap:()=>setState(()=>mode=m),child:Container(width:46,height:46,decoration:BoxDecoration(color:selected?const Color(0xFFE1E3FF):Colors.transparent,borderRadius:BorderRadius.circular(14)),child:Icon(icon,size:25,color:selected?const Color(0xFF4F569A):const Color(0xFF444444))))));}
}

class NotebookPainter extends CustomPainter {
  final List<Stroke> strokes; final double pageOffset;
  NotebookPainter({required this.strokes,required this.pageOffset});
  @override void paint(Canvas canvas,Size size){
    canvas.drawColor(Colors.white);
    final grid=Paint()..color=const Color(0xFFDCE1E8)..strokeWidth=1;
    const spacing=46.0;double y=-pageOffset%spacing;while(y<size.height){canvas.drawLine(Offset(0,y),Offset(size.width,y),grid);y+=spacing;}
    canvas.save();canvas.translate(0,-pageOffset);
    for(final s in strokes){if(s.points.length<2)continue;final p=Paint()..color=s.color..strokeWidth=s.width..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round..style=PaintingStyle.stroke;
      if(s.mode==PenMode.highlighter){p.color=s.color.withValues(alpha:.25);p.strokeWidth=math.max(s.width*4,12).toDouble();}
      if(s.mode==PenMode.eraser){p.color=Colors.white;p.strokeWidth=s.width*4;}
      final path=Path()..moveTo(s.points.first.dx,s.points.first.dy);for(int i=1;i<s.points.length;i++)path.lineTo(s.points[i].dx,s.points[i].dy);canvas.drawPath(path,p);
    }
    canvas.restore();
  }
  @override bool shouldRepaint(covariant NotebookPainter oldDelegate)=>true;
}
