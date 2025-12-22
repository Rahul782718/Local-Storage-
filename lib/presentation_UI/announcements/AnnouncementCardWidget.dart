import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/AnnouncementView_Model.dart';


class AnnouncementCardWidget extends StatefulWidget {
  bool? isShowComment;
  final AnnouncementView announcementViewData;

  AnnouncementCardWidget({super.key, this.isShowComment = false,required this.announcementViewData});

  @override
  State<AnnouncementCardWidget> createState() => _AnnouncementCardWidgetState();
}

class _AnnouncementCardWidgetState extends State<AnnouncementCardWidget> {
  bool _isShow = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),


       child: Column(
         children: [
       Container(
       height: 300.h,
         width: double.infinity,
         color: Colors.blue.shade50,
         child: ClipRRect(
           borderRadius: BorderRadius.circular(8.r),
           child: widget.announcementViewData.fileUrl != null &&
               widget.announcementViewData.fileUrl!.isNotEmpty
               ? CachedNetworkImage(
             imageUrl: widget.announcementViewData.fileUrl!,
             fit: BoxFit.cover,
             placeholder: (context, url) => Container(
               color: Colors.grey[200],
               child: Center(
                 child: CircularProgressIndicator(
                   strokeWidth: 2,
                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                 ),
               ),
             ),
             errorWidget: (context, url, error) => _buildErrorImage(),
             fadeInDuration: Duration(milliseconds: 300),
             fadeOutDuration: Duration(milliseconds: 200),
             memCacheHeight: 400, // ✅ Memory cache optimization
             memCacheWidth: 300,
           )
               : CachedNetworkImage(
             imageUrl: widget.announcementViewData.imageUrl,
             fit: BoxFit.cover,
             placeholder: (context, url) => Container(
               color: Colors.grey[200],
               child: Center(
                 child: CircularProgressIndicator(
                   strokeWidth: 2,
                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                 ),
               ),
             ),
             errorWidget: (context, url, error) => _buildErrorImage(),
             fadeInDuration: Duration(milliseconds: 300),
             fadeOutDuration: Duration(milliseconds: 200),
             memCacheHeight: 400,
             memCacheWidth: 300,
           ),
         ),
       ),

        Padding(
             padding: const EdgeInsets.all(8.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 8.verticalSpace,
                 Text("${widget.announcementViewData.title}", style: TextStyle(fontWeight: FontWeight.w500)),
                 4.verticalSpace,
                 Text("Dear Team, ", style: TextStyle(
                   fontSize: 16.sp
                 )),
                 18.verticalSpace,
                 Text(
                   "${widget.announcementViewData.description}",
                   style: TextStyle(height: 1.3),
                   overflow: TextOverflow.ellipsis,
                   maxLines: _isShow ? 100 : 2,
                 ),
                 Align(
                   alignment: Alignment.bottomRight,
                   child: GestureDetector(
                     onTap: () {
                       setState(() {
                         _isShow = !_isShow;
                       });
                     },
                     child: Text(
                       _isShow ? "Show less" : "...Show more",
                       style: TextStyle(color: Colors.blue),
                     ),
                   ),
                 ),
                 12.verticalSpace,
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Row(
                       children: [
                         Icon(Icons.thumb_up, color: Colors.blue, size: 18),
                         2.horizontalSpace,
                         Text("11", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                       ],
                     ),
                     Text("1 Comment", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                   ],
                 ),
                 if(widget.isShowComment ?? false)
                   Column(
                     children: [
                       12.verticalSpace,
                       Divider(),
                       4.verticalSpace,

                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           _iconText(Icons.thumb_up_off_alt_outlined,  "Like"),
                           _iconText(Icons.comment,  "Comment"),
                           _iconText(Icons.share,  "Share")
                         ],
                       ),
                       4.verticalSpace,
                     ],
                   )
               ],
             ),
           ),
         ],
       ),
      ),
    );
  }
  _iconText(IconData icon, String title){
    return  Row(
      children: [
        Icon(icon, color: Colors.blue, size: 18),
        2.horizontalSpace,
        Text(title, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          8.verticalSpace,
          Text(
            'Image not available',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


}