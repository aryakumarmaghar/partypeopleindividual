import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../../individual_profile_screen/profilephotoview.dart';
import '../../individual_subscription/view/subscription_view.dart';
import '../../widgets/block_unblock.dart';
import '../../widgets/my_date_utils.dart';
import '../controllers/chat_screen_controller.dart';
import '../model/chat_model.dart';

class ChatScreenView extends StatefulWidget {
  String? id;

  ChatScreenView({this.id});

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  ChatScreenController chatScreenController = Get.put(ChatScreenController());
  List<Message> listmessage = [];
  String approvalStatus = GetStorage().read('approval_status') ?? '0';
  String newUser = GetStorage().read('newUser') ?? '0';
  String plan = GetStorage().read('plan_plan_expiry') ?? 'Yes';

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;
  bool me = false;
  String indiUsername = '';

  @override
  void initState() {
    chatScreenController.getChatUserData(id: widget.id.toString());
    super.initState();
  }

  void dispose() {
    log("before last message");
    chatScreenController.getLastMessageString(
        usernameID: indiUsername+widget.id.toString(), id: widget.id.toString());
    log("after last message");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<ChatScreenController>(
          init: ChatScreenController(),
          builder: (controller) {
            indiUsername = controller.getUserModel?.data?.username ?? "";
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        //   Colors.pink,
                        // Colors.red.shade900
                        Colors.red.shade800,
                        Color(0xff7e160a),
                        Color(0xff2e0303),
                      ],
                      // begin: Alignment.topCenter,
                      //  end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                toolbarHeight: MediaQuery.of(context).size.height * 0.1,
                leading: IconButton(
                  padding: EdgeInsets.symmetric(horizontal: 18.sp),
                  alignment: Alignment.centerLeft,
                  enableFeedback: true,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Get.back();
                  },
                  iconSize: 16.sp,
                ),
                centerTitle: false,
                titleSpacing: 0.0,
                title: Row(
                  children: [
                    FittedBox(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(ProfilePhotoView(
                                profileUrl: controller
                                        .getUserModel?.data?.profilePicture ??
                                    '',
                              ));
                            },
                            child: Container(
                              width: Get.width * 0.151,
                              height: Get.width * 0.151,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: Get.width * 0.005,
                                  color: const Color(0xFFe3661d),
                                ),
                                borderRadius: BorderRadius.circular(
                                    100.sp), //<-- SEE HERE
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(Get.width * 0.006),
                                child: CircleAvatar(
                                  // backgroundImage: NetworkImage(imageURL),
                                  backgroundImage: NetworkImage(controller
                                          .getUserModel?.data?.profilePicture ??
                                      "https://firebasestorage.googleapis.com/v0/b/party-people-52b16.appspot.com/o/2-2-india-flag-png-clipart.png?alt=media&token=d1268e95-cfa5-4622-9194-1d9d5486bf54"),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: Get.width * 0.01,
                            right: Get.width * 0.001,
                            child: Container(
                              width: Get.height * 0.019,
                              height: Get.height * 0.019,
                              // color: Colors.white,
                              decoration: BoxDecoration(
                                color: const Color(0xFFe3661d),
                                borderRadius: BorderRadius.circular(100.sp),
                              ),
                              child: Icon(
                                Icons.circle,
                                color: controller
                                            .getUserModel?.data?.onlineStatus ==
                                        'on'
                                    ? Colors.green
                                    : Colors.red.shade900,
                                size: Get.height * 0.016,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 13.sp,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getUserModel?.data?.username ?? "",
                          style: TextStyle(
                              fontSize: 11.sp, fontWeight: FontWeight.w600),
                        ),
                        controller.getUserModel?.data?.onlineStatus == 'on'
                            ? Text(
                                'Online',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500),
                              )
                            : Text(
                                'Offline',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500),
                              ),
                      ],
                    )
                  ],
                ),
                actions: [
                  /*  IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.call),
                ),*/
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      // popupmenu item 1
                      PopupMenuItem(
                        value: 1,
                        // row has two child icon and text.
                        child: GestureDetector(
                          onTap: (){
                            Alertdialogs.showBlockedAlertDialog(context, '${controller.getUserModel?.data?.id}', 'Block');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.block,color: Colors.black),
                              SizedBox(
                                // sized box with width 10
                                width: 10,
                              ),
                              Text("   Block   ",style: TextStyle(color: Colors.black),)
                            ],
                          ),
                        ),
                      ),
                      // popupmenu item 2
                      PopupMenuItem(
                        value: 2,
                        // row has two child icon and text
                        child: GestureDetector(
                          onTap: (){
                          controller.deleteAllMessage('${controller.getUserModel?.data?.username}${controller.getUserModel?.data?.id}');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.chrome_reader_mode,color: Colors.black,),
                              SizedBox(
                                // sized box with width 10
                                width: 10,
                              ),
                              Text("   Delete All chat",style: TextStyle(color: Colors.black))
                            ],
                          ),
                        ),
                      ),
                    ],
                    offset: Offset(0, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    color: Colors.white,
                    elevation: 5,
                  ),
                /*  IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.more_vert),
                  ),*/
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22.sp),
                    //     top: Radius.circular(22.sp),
                  ),
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: StreamBuilder(
                        stream:
                            controller.getAllMessages(controller.getUserModel),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const SizedBox();

                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              listmessage = data
                                      ?.map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (listmessage.isNotEmpty) {
                                return ListView.builder(
                                    reverse: true,
                                    itemCount: listmessage.length,
                                    padding:
                                        EdgeInsets.only(top: Get.height * .01),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (listmessage[index].fromId ==
                                          controller.myUsername+controller.myUserId) {
                                        me = true;
                                        log('me ::::::::::: $me');
                                      }
                                      var data = listmessage[index];
                                      //data.toId == controller.myUsername+controller.myUserId;
                                      var time =
                                          '${DateFormat('d MMMM y ,hh:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(data.sent)))}';
                                      return GestureDetector(
                                        onLongPress:(){
                                          FocusScope.of(context).requestFocus(FocusNode());
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return SimpleDialog(
                                              shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(16.0),
                                              bottomRight: Radius.circular(16.0),
                                              topLeft: Radius.circular(16.0),
                                              topRight: Radius.circular(16.0),
                                              ),
                                              ),
                                              backgroundColor: Color(0xff7e160a),
                                              elevation: 5,
                                               // title:Center(child: const Text('Delete Message',style: TextStyle(color: Colors.black),)),
                                                children: <Widget>[
                                                  SimpleDialogOption(
                                                    onPressed: () async{
                                                      await controller.deleteMessage(listmessage[index]);
                                                      Navigator.pop(context);
                                                      },
                                                    child:Center(child: const Text('Delete',style: TextStyle(fontSize: 18))),
                                                  ),
                                                  /*  SimpleDialogOption(
              onPressed: () { },
              child: const Text('Option 2'),
            ),*/
                                                ],
                                              );
                                            },
                                        );



                                        } ,
                                        child:  listmessage[index].fromDeleteStatus != controller.myUsername+controller.myUserId ?
                                        MessageContainer(
                                          message: listmessage[index],
                                          text: listmessage[index].msg,
                                          isMe:
                                              data.fromId == controller.myUsername+controller.myUserId
                                                  ? true
                                                  : false,
                                          time: data.sent,
                                          pic: controller.getUserModel?.data
                                                  ?.profilePicture ??
                                              '',
                                          updateReadMessage: () =>
                                              controller.updateMessageReadStatus(
                                                  listmessage[index]),
                                         // myChatId: controller.myUsername+controller.myUserId,
                                         // deletemsg:()=> controller.deleteMessage(listmessage[index]),
                                        ):Container(),
                                      );
                                    });
                              } else {
                                return const Center(
                                  child: Text(
                                    'Say Hii! 👋',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                );
                              }
                          }
                        }),
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      18.sp,
                    ),
                    padding: EdgeInsets.only(left: 15.0.sp, right: 7.sp),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            //   Colors.pink,
                            // Colors.red.shade900
                            Colors.red.shade800,
                            Color(0xff7e160a),
                            Color(0xff2e0303),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                            topRight: Radius.circular(100))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        /*  IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                        color: Color(0xFFf7aa07),
                      ),*/
                        Expanded(
                          child: TextField(
                            onChanged: (value) {},
                            controller: _textController,
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.sp, horizontal: 16.sp),
                              hintText: 'Type your message here',
                              hintStyle: TextStyle(
                                  color: Color(0xffd4d3d5), fontSize: 12.sp),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (plan == 'Yes') {
                              if (newUser == '1') {
                                if (_textController.text.isNotEmpty) {
                                  if (listmessage.isEmpty) {
                                    if (controller.userId != '0') {
                                      controller.addChatUserToList();
                                    }
                                  }
                                  controller.sendMessage(
                                      controller.getUserModel,
                                      _textController.text,
                                      Type.text);
                                  _textController.text = '';
                                } else {
                                  Get.snackbar(
                                      'Message', 'Please type here first');
                                }
                              } else {
                                if (me == true) {
                                  if (_textController.text.isNotEmpty) {
                                    if (listmessage.isEmpty) {
                                      if (controller.userId != '0') {
                                        controller.addChatUserToList();
                                      }
                                    }
                                    controller.sendMessage(
                                        controller.getUserModel,
                                        _textController.text,
                                        Type.text);
                                    _textController.text = '';
                                  } else {
                                    Get.snackbar(
                                        'Message', 'Please type here first');
                                  }
                                } else {
                                  Get.to(SubscriptionView(
                                    subText: 'For Initiate chat or reply ',
                                    iconText:
                                        'https://assets-v2.lottiefiles.com/a/5e232bde-1182-11ee-b778-8f3af2eeaa9d/4xBFTBXlHa.json',
                                  ));
                                }
                              }
                            }
                            else {
                              if (_textController.text.isNotEmpty) {
                                if (listmessage.isEmpty) {
                                  if (controller.userId != '0') {
                                    controller.addChatUserToList();
                                  }
                                }
                                controller.sendMessage(controller.getUserModel,
                                    _textController.text, Type.text);
                                _textController.text = '';
                              } else {
                                Get.snackbar(
                                    'Message', 'Please type here first');
                              }
                            }
                          },
                          child: Container(
                            width: Get.width * 0.2,
                            color: Colors.transparent,
                            /*  decoration:
                          BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.sp),
                              bottomLeft: Radius.circular(16.sp),
                              bottomRight: Radius.circular(16.sp),
                            ),
                            color: Color(0xFF3f02ca),
                          ),*/
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.sp, vertical: 5.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class MessageContainer extends StatelessWidget {
  MessageContainer(
      {required this.text,
      required this.isMe,
      required this.time,
      required this.message,
      required this.pic,
      required this.updateReadMessage,
      //required this.myChatId,
    //  required this.deletemsg
   });

  Message? message;
  String text;
  bool isMe;
  String time;
  String pic;
  Function updateReadMessage;
 // String myChatId;
//  Function deletemsg;

  @override
  Widget build(BuildContext context) {
    bool? readStatus = message?.read.toString().isEmpty;
    if (readStatus == true) {
      updateReadMessage();
    }
    //return message?.fromDeleteStatus != myChatId ?
   return Padding(
        padding: EdgeInsets.only(left: 10.sp, top: 8, bottom: 8, right: 10),
        child: isMe == true
            ?
            // my messages
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                            borderRadius: isMe
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(14.sp),
                                    bottomLeft: Radius.circular(14.sp),
                                    topRight: Radius.circular(14.sp))
                                : BorderRadius.only(
                                    topRight: Radius.circular(14.sp),
                                    bottomLeft: Radius.circular(14.sp),
                                    bottomRight: Radius.circular(14.sp)),
                            color: Colors.red.shade50
                            //  color: isMe ? Color(0xFFefeef0) : Color(0xFF49d298),
                            ),
                        child: Padding(
                          padding: EdgeInsets.all(6.sp),
                          child: Text(
                            text,
                            style: TextStyle(
                                fontSize: 12 .sp,
                                height: 1.sp,
                                color: isMe ? Color(0xFF85828a) : Colors.white),
                          ),
                        ),
                      ),
                      Row(children: [
                        Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: '${time}'),
                          style:
                          TextStyle(color: Color(0xffd4d3d5), fontSize: 9.sp),
                        ),
                        SizedBox(
                          width: 2.sp,
                        ),
                        readStatus == true
                            ? Icon(
                          Icons.done_all,
                          color: Colors.grey,
                          size: 13.sp,
                        )
                            : Icon(
                          Icons.done_all,
                          color: Color(0xFF49d298),
                          size: 13.sp,
                        ),

                      ]),

                    ],
                  ),
                ],
              )
            :
            // sender or another user messages
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: Get.width * 0.085,
                                height: Get.width * 0.085,
                                /* decoration: BoxDecoration(
                                      border: Border.all(
                                        width: Get.width * 0.005,
                                        color: const Color(0xFFe3661d),
                                      ),
                                      borderRadius: BorderRadius.circular(100.sp), //<-- SEE HERE
                                    ),*/
                                child: Padding(
                                  padding: EdgeInsets.all(Get.width * 0.006),
                                  child: CircleAvatar(
                                    // backgroundImage: NetworkImage(imageURL),
                                    backgroundImage: NetworkImage(pic),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 2.sp,
                              ),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.6),
                                decoration: BoxDecoration(
                                  borderRadius: isMe
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(14.sp),
                                          bottomLeft: Radius.circular(14.sp),
                                          topRight: Radius.circular(14.sp))
                                      : BorderRadius.only(
                                          topRight: Radius.circular(14.sp),
                                          topLeft: Radius.circular(14.sp),
                                          bottomRight: Radius.circular(14.sp)),
                                  color: isMe
                                      ? Color(0xFFefeef0)
                                      : Colors.red.shade900,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10.sp),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        height: 1.sp,
                                        color: isMe
                                            ? Color(0xFF85828a)
                                            : Colors.white),
                                  ),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 2.sp,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: Get.width * 0.1),
                          child: Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: '${time}'),
                            style: TextStyle(
                                color: Color(0xffd4d3d5), fontSize: 9.sp),
                          ),
                        ),
                      ]),
                ],
              )) ;
  }
}
