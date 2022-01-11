import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexus/models/PostModel.dart';
import 'package:nexus/models/userModel.dart';
import 'package:nexus/providers/manager.dart';
import 'package:nexus/screen/editProfile.dart';
import 'package:nexus/services/AuthService.dart';
import 'package:nexus/utils/devicesize.dart';
import 'package:nexus/utils/firebaseServices.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class profiletScreen extends StatefulWidget {
  @override
  State<profiletScreen> createState() => _profiletScreenState();
}

class _profiletScreenState extends State<profiletScreen> {
  bool viewPosts = true;
  File? imagefile;
  final picker = ImagePicker();
  bool? loadScreen;
  User? currentUser;
  bool init = true;
  final authservice _auth = authservice(FirebaseAuth.instance);
  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    loadScreen = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      Provider.of<usersProvider>(context)
          .fetchUser(currentUser!.uid)
          .then((value) {
        loadScreen = false;
        init = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future pickImageForCoverPicture() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (mounted) {
        setState(() {
          loadScreen = true;
        });
        Provider.of<usersProvider>(context, listen: false)
            .addCoverPicture(
                File(pickedFile!.path), currentUser!.uid.toString())
            .then((value) {
          setState(() {
            loadScreen = false;
          });
        });
      }
    }

    Future pickImageForProfilePicture() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (mounted) {
        setState(() {
          loadScreen = true;
        });
        Provider.of<usersProvider>(context, listen: false)
            .addProfilePicture(
                File(pickedFile!.path), currentUser!.uid.toString())
            .then((value) {
          setState(() {
            loadScreen = false;
          });
        });
      }
    }

    NexusUser? myProfile =
        Provider.of<usersProvider>(context, listen: false).fetchCurrentUser;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: displayHeight(context),
          width: displayWidth(context),
          color: Colors.white,
          child: (loadScreen!)
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                    backgroundColor: Colors.blue,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: displayHeight(context) * 0.28,
                        width: displayWidth(context),
                        //color: Colors.pink,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: 0,
                              child: (myProfile!.coverImage != '')
                                  ? CachedNetworkImage(
                                      imageUrl: myProfile.coverImage,
                                      height: displayHeight(context) * 0.28,
                                      width: displayWidth(context),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'images/cover.jpg',
                                      height: displayHeight(context) * 0.28,
                                      width: displayWidth(context),
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            Container(
                              width: displayWidth(context),
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                    Colors.transparent,
                                    Colors.white
                                  ],
                                      stops: [
                                    0,
                                    .8
                                  ])),
                            ),
                            Positioned(
                                top: displayHeight(context) * 0.16,
                                left: displayWidth(context) * 0.04,
                                child: Container(
                                  height: displayHeight(context) * 0.1,
                                  width: displayWidth(context) * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                        color: Colors.orangeAccent, width: 2.3),
                                  ),
                                )),
                            Positioned(
                                top: displayHeight(context) * 0.075,
                                right: displayWidth(context) * 0.02,
                                child: IconButton(
                                  iconSize: displayWidth(context) * 0.075,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: displayHeight(context) * 0.18,
                                          width: displayWidth(context),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    pickImageForCoverPicture();
                                                  },
                                                  child: Text(
                                                    'Change Cover Picture',
                                                    style: TextStyle(
                                                        fontSize: displayWidth(
                                                                context) *
                                                            0.05,
                                                        color: Colors.black45,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              Divider(),
                                              TextButton(
                                                onPressed: () {
                                                  pickImageForProfilePicture();
                                                },
                                                child: Text(
                                                  'Change Profile Picture',
                                                  style: TextStyle(
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.05,
                                                      color: Colors.black45,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  color: Colors.white70,
                                  icon: Icon(Icons.add_a_photo),
                                )),
                            Positioned(
                                top: displayHeight(context) * 0.15,
                                right: displayWidth(context) * 0.02,
                                child: IconButton(
                                  iconSize: displayWidth(context) * 0.08,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              editProfileScreen(
                                            user: myProfile,
                                          ),
                                        ));
                                  },
                                  color: Colors.white70,
                                  icon: Icon(Icons.edit),
                                )),
                            Positioned(
                                top: displayHeight(context) * 0.1655,
                                left: displayWidth(context) * 0.052,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: (myProfile.dp != '')
                                      ? CachedNetworkImage(
                                          imageUrl: myProfile.dp,
                                          height:
                                              displayHeight(context) * 0.0905,
                                          width: displayWidth(context) * 0.175,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'images/male.jpg',
                                          height:
                                              displayHeight(context) * 0.0905,
                                          width: displayWidth(context) * 0.175,
                                          fit: BoxFit.cover,
                                        ),
                                )),
                            Positioned(
                                top: displayHeight(context) * 0.02,
                                child: Text(
                                  myProfile.title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: displayWidth(context) * 0.05,
                                      letterSpacing: 0.8),
                                )),
                            Positioned(
                                right: displayWidth(context) * 0.02,
                                top: displayHeight(context) * 0.005,
                                child: IconButton(
                                  iconSize: displayWidth(context) * 0.08,
                                  icon: const Icon(Icons.logout),
                                  onPressed: () async {
                                    // Logout
                                  },
                                  color: Colors.white70,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              myProfile.username,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: displayWidth(context) * 0.045,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Opacity(
                        opacity: 0.0,
                        child: Divider(
                          height: displayHeight(context) * 0.01,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: (myProfile.bio != '')
                            ? Container(
                                child: Text(
                                  myProfile.bio,
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            : SizedBox(),
                      ),
                      Opacity(
                        opacity: 0.0,
                        child: Divider(
                          height: displayHeight(context) * 0.01,
                        ),
                      ),
                      Container(
                        height: displayHeight(context) * 0.1,
                        width: displayWidth(context),
                        //color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  myProfile.followers.length.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: displayWidth(context) * 0.04),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: displayWidth(context) * 0.036),
                                )
                              ],
                            )),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  myProfile.followings.length.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: displayWidth(context) * 0.04),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: displayWidth(context) * 0.036),
                                ),
                              ],
                            )),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  myProfile.posts.length.toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: displayWidth(context) * 0.04),
                                ),
                                Text(
                                  'Posts',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: displayWidth(context) * 0.036),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                      const Opacity(
                        opacity: 0.0,
                        child: Divider(
                          height: 2,
                        ),
                      ),
                      Container(
                        height: displayHeight(context) * 0.08,
                        width: displayWidth(context) * 0.62,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (!viewPosts) {
                                      viewPosts = !viewPosts;
                                    }
                                  });
                                },
                                child: (viewPosts)
                                    ? Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 45.0,
                                                right: 45,
                                                top: 8,
                                                bottom: 8),
                                            child: Text(
                                              'Posts',
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.042,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Posts',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize:
                                                displayWidth(context) * 0.042,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (viewPosts) {
                                      viewPosts = !viewPosts;
                                    }
                                  });
                                },
                                child: (!viewPosts)
                                    ? Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 45.0,
                                                right: 45,
                                                top: 8,
                                                bottom: 8),
                                            child: Text(
                                              'Saved',
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.042,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Saved',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize:
                                                displayWidth(context) * 0.042,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        //dragStartBehavior: DragStartBehavior.down,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemCount: myProfile.posts.length,
                        padding: const EdgeInsets.all(8),

                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                  height: displayHeight(context) * 0.1,
                                  width: displayWidth(context) * 0.3,
                                  fit: BoxFit.cover,
                                  imageUrl: myProfile.posts[index]['image']),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
