import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';
import 'package:np_mobile/datamodel/np_module.dart';
import 'package:np_mobile/service/entry_service.dart';
import 'package:np_mobile/ui/blocs/application_state_provider.dart';
import 'package:np_mobile/ui/widgets/entry_view_util.dart';

const double _kMinFlingVelocity = 400.0;

class EntryViewWidget extends StatefulWidget {
  const EntryViewWidget({Key key, this.entry}) : super(key: key);
  final NPEntry entry;

  @override
  _EntryViewWidgetState createState() => _EntryViewWidgetState();
}

class _EntryViewWidgetState extends State<EntryViewWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  NPEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
    if (_entry.moduleId == NPModule.DOC) {
      EntryService().get(NPModule.DOC, _entry.entryId, _entry.owner.userId).then((doc) {
        if (this.mounted) {
          setState(() {
            _entry = doc;
          });
        }
      });
    }
    _controller = AnimationController(vsync: this)..addListener(_handleFlingAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final organizeBloc = ApplicationStateProvider.forOrganize(context);

    if (_entry.moduleId == NPModule.PHOTO) {
      return GestureDetector(
        onScaleStart: _handleOnScaleStart,
        onScaleUpdate: _handleOnScaleUpdate,
        onScaleEnd: _handleOnScaleEnd,
        child: ClipRect(
          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: EntryViewUtil.fullPage(_entry, context, (entry) {
              if (this.mounted) {
                setState(() {
                });
              }
            }),
          ),
        ),
      );

    } else {
      return StreamBuilder(
        stream: organizeBloc.updateStream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            NPEntry updatedEntry = snapshot.data;
            // only update the stream when the entry Id matches. the situation below fits:
            // entry view -> entry edit -> save and return to view
            if (_entry.moduleId == updatedEntry.moduleId && _entry.entryId == updatedEntry.entryId) {
              _entry = updatedEntry;
              organizeBloc.resetUpdate();
            }
          }
          return EntryViewUtil.fullPage(_entry, context, (entry) {
            if (this.mounted) {
              setState(() {
                _entry = entry;
              });
            }
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation =
        _controller.drive(Tween<Offset>(begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }
}
