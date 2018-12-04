import 'package:flutter/material.dart';
import 'package:np_mobile/datamodel/np_entry.dart';

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }

class EntryTile extends ListTile {
  final NPEntry _entry;

  EntryTile(NPEntry entry): _entry = entry;

  @override
  get onTap {
    return super.onTap;
  }

  @override
  Widget get leading => super.leading;

  @override
  Widget get title {
    return new Row(
      children: <Widget>[
        new Expanded(child: new Text(_entry.title)),
        new PopupMenuButton<WhyFarther>(
          onSelected: (WhyFarther result) {

          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.harder,
              child: Text('Working a lot harder'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.smarter,
              child: Text('Being a lot smarter'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.selfStarter,
              child: Text('Being a self-starter'),
            ),
            const PopupMenuItem<WhyFarther>(
              value: WhyFarther.tradingCharter,
              child: Text('Placed in charge of trading charter'),
            ),
          ],
        )
      ],
    );
  }
}