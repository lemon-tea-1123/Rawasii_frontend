
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FullScreenCarousel extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenCarousel({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenCarousel> createState() => _FullScreenCarouselState();
}

class _FullScreenCarouselState extends State<FullScreenCarousel> {
  late PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        // e.g. "3 / 5"
        title: widget.images.length > 1
            ? Text('${_current + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14))
            : null,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          // ── Swipeable full images ──
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              return InteractiveViewer( // pinch to zoom
                child: Center(
                  child: Hero(
                    tag: i == widget.initialIndex
                        ? 'image_${widget.initialIndex}'
                        : 'image_extra_$i',
                    child: kIsWeb
                        ? Image.network(widget.images[i], fit: BoxFit.contain)
                        : Image.file(File(widget.images[i]),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image,
                                    color: Colors.white)),
                  ),
                ),
              );
            },
          ),

          // ── Dot indicators ──
          if (widget.images.length > 1)
            Positioned(
              bottom: 24,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 8 : 6,
                    height: _current == i ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == i
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  );
                }),
              ),
            ),

        ],
      ),
    );
  }
}