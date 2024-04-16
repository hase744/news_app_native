import 'package:flutter/material.dart';
import 'package:video_news/consts/colors.dart';
import 'package:video_news/models/channel.dart';
import 'package:video_news/models/channel_mode.dart';
class ChannelCell extends StatelessWidget {
  Channel channel;
  double width;
  ChannelMode mode;
  Function() onSelected;
  Function() onRemoved;
  
  ChannelCell({
    super.key,
    required this.channel,
    required this.width,
    required this.mode,
    required this.onSelected,
    required this.onRemoved,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: width/20*4,
      width: width,
      decoration: BoxDecoration(
        border: Border(
          bottom: 
          BorderSide(
            color: ColorConfig.settingBorder,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: 
            InkWell(
              onTap: onSelected,
              child: 
              Row(
                children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width/20),
                  width: width*3/20,
                  height: width*3/20,
                  child: 
                  ClipRRect(
                    borderRadius: BorderRadius.circular(width),
                    child:
                    Image.network(channel.imageUrl)
                  )
                ),
                Container(
                  width: width -width*2/20 - width*3/20 - (mode == ChannelMode.select? width/20*3 : 0),
                  child:  Text(
                    channel.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width/20,
                    ),
                  ),
                ),
              ],
              ),
            )
          ),
          if(mode == ChannelMode.select)
          IconButton(
            iconSize: width/20*2,
            icon: const Icon(Icons.close),
            onPressed: onRemoved
          )
        ],
      )
    );
  }
}