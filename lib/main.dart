import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: WhatsAppOnboardingFinal(),
));

class WhatsAppOnboardingFinal extends StatefulWidget {
  const WhatsAppOnboardingFinal({super.key});

  @override
  State<WhatsAppOnboardingFinal> createState() => _WhatsAppOnboardingFinalState();
}

class _WhatsAppOnboardingFinalState extends State<WhatsAppOnboardingFinal> {
  final PageController _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  final List<SlideData> slides = [
    SlideData("How much\nof my earnings\ndo I get to keep?", "100%.\nWe charge zero\ncommission on\nyour sales.", const Color(0xFF3BAE67)),
    SlideData("Will I get paid\non time,\nand it it safe?", "Always.\nPayment are \nsecure and\non-time\nevery time.", const Color(0xFF2596be)),
    SlideData("Can I reach more\ncustomers beyond\nmy area?", "Yes!\nWe deliver to\n20,000+ pin codes\nacross India.", const Color(0xFF9962b3)),
    SlideData("What if most of my\nsales happen offline?", "No worries\noffline exposure is\npart of the plan.", const Color(0xFFF18C33)),
    SlideData("How do I minimize\nreturns and losses?", "With us,\nyou get fewer\nreturns and\nmore profit.", const Color(0xFFE84C3D)),
  ];

  @override
  Widget build(BuildContext context) {
    bool isVisible = _currentPage > 0.1 && _currentPage < slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: slides.length,
            itemBuilder: (context, index) => SlidePage(
              key: ValueKey(index),
              data: slides[index],
            ),
          ),

          // --- ANIMATED SKIP BUTTON ---
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              // Offset(1, 0) means it starts off-screen to the right
              offset: isVisible ? Offset.zero : const Offset(2.0, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isVisible ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      slides.length - 1,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "SKIP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class SlidePage extends StatefulWidget {
  final SlideData data;
  const SlidePage({super.key, required this.data});

  @override
  State<SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<SlidePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.data.color,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _curvedAnimation,
                  builder: (context, child) {
                    final double fontSize = lerpDouble(36, 24, _curvedAnimation.value);
                    final Color? textColor = Color.lerp(Colors.white, Colors.black, _curvedAnimation.value);
                    return Text(
                      widget.data.question,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    );
                  },
                ),
                SizeTransition(
                  sizeFactor: _curvedAnimation,
                  axis: Axis.vertical,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Opacity(opacity: 0, child: Text(widget.data.answer, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, height: 1.1))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 0,
                  child: AnimatedBuilder(
                    animation: _curvedAnimation,
                    builder: (context, child) => Text(
                      widget.data.question,
                      style: TextStyle(fontSize: lerpDouble(36, 24, _curvedAnimation.value), fontWeight: FontWeight.bold, height: 1.1),
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _curvedAnimation,
                  axis: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _curvedAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _curvedAnimation.value,
                            child: Transform.translate(
                              offset: Offset(250 * (1 - _curvedAnimation.value), 0),
                              child: Text(
                                widget.data.answer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

class SlideData {
  final String question, answer;
  final Color color;
  SlideData(this.question, this.answer, this.color);
}