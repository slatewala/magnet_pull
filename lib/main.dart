import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MagnetPullApp());

class MagnetPullApp extends StatelessWidget {
  const MagnetPullApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Magnet Pull',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const GamePage(),
      );
}

class Ball {
  Offset p, v;
  final Color color;
  Ball(this.p, this.v, this.color);
}

class Goal {
  final Offset p;
  final Color color;
  bool filled = false;
  Goal(this.p, this.color);
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final _sfx = AudioPlayer();
  final _rng = Random();
  List<Ball> _balls = [];
  List<Goal> _goals = [];
  Offset? _magnet;
  int _level = 1;
  int _score = 0;
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  void _setup() {
    final s = MediaQuery.of(context).size;
    _size = s;
    final cs = [const Color(0xFFFF4D6D), const Color(0xFF4DD0E1), const Color(0xFFFFEA00)];
    _balls = List.generate(_level + 1, (i) {
      final c = cs[i % cs.length];
      return Ball(
        Offset(60 + _rng.nextDouble() * (s.width - 120),
            120 + _rng.nextDouble() * (s.height * 0.4)),
        Offset.zero,
        c,
      );
    });
    _goals = List.generate(_balls.length, (i) {
      final c = _balls[i].color;
      return Goal(
        Offset(60 + _rng.nextDouble() * (s.width - 120),
            s.height * 0.6 + _rng.nextDouble() * (s.height * 0.2)),
        c,
      );
    });
    setState(() {});
  }

  void _tick(Duration t) {
    final dt = (t - _last).inMicroseconds / 1e6;
    _last = t;
    if (dt > 0.1 || _size == Size.zero) return;
    setState(() {
      for (final b in _balls) {
        if (_magnet != null) {
          final d = _magnet! - b.p;
          final dist = max(20.0, d.distance);
          final f = 12000 / (dist * dist);
          b.v += d / dist * f * dt;
        }
        b.v *= 0.985;
        b.p += b.v * dt;
        if (b.p.dx < 20 || b.p.dx > _size.width - 20) b.v = Offset(-b.v.dx, b.v.dy);
        if (b.p.dy < 20 || b.p.dy > _size.height - 20) b.v = Offset(b.v.dx, -b.v.dy);
        b.p = Offset(b.p.dx.clamp(20, _size.width - 20),
            b.p.dy.clamp(20, _size.height - 20));
      }
      for (final g in _goals) {
        if (g.filled) continue;
        for (final b in _balls) {
          if ((b.p - g.p).distance < 30 && b.color == g.color) {
            g.filled = true;
            _score++;
            _sfx.play(AssetSource('sfx.wav'));
            break;
          }
        }
      }
      if (_goals.every((g) => g.filled)) {
        _level++;
        _setup();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _sfx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => setState(() => _magnet = e.localPosition),
        onPointerMove: (e) => setState(() => _magnet = e.localPosition),
        onPointerUp: (_) => setState(() => _magnet = null),
        onPointerCancel: (_) => setState(() => _magnet = null),
        child: Stack(children: [
          CustomPaint(
            size: Size.infinite,
            painter: _Painter(balls: _balls, goals: _goals, magnet: _magnet),
          ),
          Positioned(
            top: 50, left: 0, right: 0,
            child: Column(children: [
              Text('LEVEL $_level',
                  style: const TextStyle(fontSize: 18, color: Colors.white60)),
              Text('$_score',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            ]),
          ),
          const Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: Text('hold + drag = magnet · match colors to goals',
                  style: TextStyle(color: Colors.white38)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final List<Ball> balls;
  final List<Goal> goals;
  final Offset? magnet;
  _Painter({required this.balls, required this.goals, required this.magnet});
  @override
  void paint(Canvas c, Size s) {
    for (final g in goals) {
      final p = Paint()
        ..color = g.color.withOpacity(g.filled ? 0.9 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      c.drawCircle(g.p, 30, p);
      if (g.filled) {
        c.drawCircle(g.p, 24, Paint()..color = g.color);
      }
    }
    for (final b in balls) {
      c.drawCircle(b.p, 16, Paint()..color = b.color);
    }
    if (magnet != null) {
      // pulsing rings — high contrast, visible on dark bg
      c.drawCircle(magnet!, 80,
          Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.10));
      c.drawCircle(magnet!, 50,
          Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.20));
      c.drawCircle(magnet!, 30,
          Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.45));
      c.drawCircle(magnet!, 18, Paint()..color = Colors.white);
      c.drawCircle(magnet!, 8, Paint()..color = const Color(0xFFFF4D6D));
      // outer ring outline for clarity
      c.drawCircle(magnet!, 80,
          Paint()
            ..color = Colors.white70
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) => true;
}
