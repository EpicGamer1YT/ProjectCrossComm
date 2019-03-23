import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  Bubble({this.message, this.time, this.delivered, this.isMe, this.userInit});

  final String message, time, userInit;
  final delivered, isMe;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.grey : Colors.blue.shade300;
    final align = isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final align2 = isMe ? MainAxisAlignment.start : MainAxisAlignment.end;
    final icon = delivered ? Icons.done_all : Icons.done;
    final radius = isMe
        ? BorderRadius.only(
      topRight: Radius.circular(15.0),
      bottomLeft: Radius.circular(15.0),
      bottomRight: Radius.circular(15.0),
      topLeft: Radius.circular(15.0)
    )
        : BorderRadius.only(
      topLeft: Radius.circular(15.0),
      bottomLeft: Radius.circular(15.0),
      bottomRight: Radius.circular(15.0),
      topRight: Radius.circular(15.0)
    );
    return Row(
      children: <Widget>[
        isMe ? new CircleAvatar(
          maxRadius: 15.0,
          minRadius: 3.0,
          backgroundColor: Colors
              .red,
          child: new Text(
            userInit,
            style: new TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ) : new Container(),
        new Expanded(child: Column(
          mainAxisAlignment: align2,
          crossAxisAlignment: align,
          children: <Widget>[

            Container(
              margin: const EdgeInsets.all(3.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: .5,
                      spreadRadius: 1.0,
                      color: Colors.black.withOpacity(.12))
                ],
                color: bg,
                borderRadius: radius,
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 20.0, bottom: 15.0),
                    child: Text(message, style: Theme.of(context).textTheme.display1,),
                  ),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Row(
                      children: <Widget>[
                        Text(time,
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 10.0,
                            )),
                        SizedBox(width: 3.0),
                        Icon(
                          icon,
                          size: 12.0,
                          color: Colors.black38,
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        )),

      ],
    );

  }
}