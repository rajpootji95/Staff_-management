import 'dart:async';

import 'package:fieldmanager_hrms_flutter/screens/Chat/url_message.dart';
import 'package:fieldmanager_hrms_flutter/utils/app_colors.dart';
import 'package:fieldmanager_hrms_flutter/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/chat_response.dart';
import '../../utils/app_widgets.dart';

class ChattingScreen extends StatefulWidget {
  static String tag = '/ChattingScreen';
  const ChattingScreen({Key? key, this.alertMsg}) : super(key: key);
  final String? alertMsg;
  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  ChatResponse _response = ChatResponse(chatItems: []);
  bool _isLoading = false;
  var messageCont = TextEditingController();
  late Timer timer;

  void init() async {
    setState(() {
      _isLoading = true;
    });
    var result = await apiRepo.getChats();
    if (result != null) {
      _response = result;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void setupSync() async {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      var result = await apiRepo.getChats();
      if (result != null) {
        if (result.chatItems.isNotEmpty &&
            result.chatItems.first != _response.chatItems.first) {
          setState(() {
            _response.chatItems = result.chatItems;
          });
        }
      }
    });
  }

  /*{
    "latitude": 31.554492,
    "longitude": 74.3634996,
    "date": "March 28, 2024, 10:24:02 PM",
    "emergency": "A user needs emergency service",
    "user_Img": "https://firebasestorage.googleapis.com/v0/b/karzame-f00a9.appspot.com/o/UserPics%2Ffile%3A%2Fstorage%2Femulated%2F0%2FAndroid%2Fdata%2Fcom.karzamee.app%2Ffiles%2FPictures%2F708036d3-7196-4704-96ca-c0ad244a9602_1691814505538.jpg?alt=media&token=cb4b0ad3-6ab5-48e2-90b8-d1401c501499",
     "user_Name": "karzame",
     "user_Phone": "+18166026983"
}*/

  alertDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 5,
                      spreadRadius: 2,
                      color: grey,
                      offset: Offset(2, 3))
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6)
                    ),
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      fit: BoxFit.cover,
                    )),
                10.height,
                Text(
                  "Kidnapping Alert",
                  style: primaryTextStyle(color: purple, size: 18),
                ),
                8.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Flexible(
                      child: Text(
                        "This Person Who Appears on the  picture as being kidnap along Effurun Sapele Road, Effurun at 12:00",
                        style: primaryTextStyle(color: white, size: 13),
                        textAlign: TextAlign.center,
                      )),
                ),
                20.height,
                AppButton(
                  height: 24,
                  color: greenColor,
                  child: Text(
                    "Locate Victim",
                    style: primaryTextStyle(color: white, size: 16),
                  ),
                  onTap: () {},
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void sendMessage() async {
    setState(() {
      _isLoading = true;
    });

    var result = await apiRepo.postChat(messageCont.text);
    if (result) {
      messageCont.text = '';
      init();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
    if(widget.alertMsg != null){
      messageCont.text = widget.alertMsg??"";
    }
    setupSync();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBar(context, language!.lblChats),
      body: !_isLoading
          ? Stack(
              children: [
                _response.chatItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Text(language!.lblNoMessages),
                        ),
                      )
                    : ListView.builder(
                        itemBuilder: (context, i) =>
                            buildChatMessages(_response.chatItems[i]!),
                        itemCount: _response.chatItems.length,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 10, bottom: 60),
                        reverse: true,
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 6, right: 6, bottom: 3),
                    child: typingSection(width),
                  ),
                ),
              ],
            )
          : loadingWidgetMaker(),
    );
  }

  Widget typingSection(double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        width: width,
        decoration:
            boxDecorationRoundedWithShadow(10, backgroundColor: opPrimaryColor),
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //Icon(Icons.insert_emoticon, color: appStore.textPrimaryColor),
            5.width,
            Expanded(
              child: TextFormField(
                controller: messageCont,
                // autofocus: true,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                    color: appStore.textPrimaryColor,
                    fontSize: fontSizeMedium,
                    fontFamily: fontRegular),
                decoration: InputDecoration(
                  hintText: language!.lblTypeYourMessage,
                  filled: true,
                  fillColor: appStore.isDarkModeOn ? cardDarkColor : white,
                  contentPadding: const EdgeInsets.all(5.0),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: editTextBackground, width: 0.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: editTextBackground, width: 0.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.send,
                size: 30,
                color: white,
              ).onTap(() {
                if (!messageCont.text.isEmptyOrNull) {
                  sendMessage();
                } else {
                  toast(language!.lblPleaseTypAMessageFirst);
                }
              }),
            )
          ],
        ),
      ),
    );
  }
  static const pattern =
      r"(https?:\/\/(www.)?|www.)([\w-]+.([\w-]+.)?[\w]+)([\w./?=%-]*)";
  final regExp = RegExp(pattern);
  bool hasURLs(String text) {
    return regExp.hasMatch(text);
  }


  Widget buildChatMessages(ChatItem model) {
    if (model.from.isEmptyOrNull) {
      return Container(
        margin: const EdgeInsets.only(right: 3, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: const BoxDecoration(
                  color: opPrimaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language!.lblYou,
                    style:
                        const TextStyle(fontSize: fontSizeSmall, color: white),
                  ),
                  UrlMessage(textContent: model.message!, textColor: white, isMyMessage: true),
                  // InkWell(
                  //   onTap: (){
                  //     if(!hasURLs(model.message!))return;
                  //   },
                  //   child: Text(model.message!,
                  //       style: const TextStyle(
                  //           color: white,
                  //           fontSize: fontSizeMedium,
                  //           overflow: TextOverflow.visible)),
                  // )
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: model.createdAt,
                      style: const TextStyle(
                          fontSize: fontSizeSmall, color: textSecondaryColor)),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 3, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    appStore.isDarkModeOn ? cardDarkColor : opDarkWidgetColor,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.from!,
                    style:
                        const TextStyle(fontSize: fontSizeSmall, color: white),
                  ),
                  UrlMessage(textContent: model.message!, textColor: white, isMyMessage: false),
                  // Text(model.message!,
                  //     style: const TextStyle(
                  //         color: white,
                  //         fontSize: fontSizeMedium,
                  //         overflow: TextOverflow.visible))
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: model.createdAt,
                      style: const TextStyle(
                          fontSize: fontSizeSmall, color: textSecondaryColor)),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}
