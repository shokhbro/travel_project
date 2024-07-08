import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_project/controllers/travel_controller.dart';
import 'package:travel_project/services/location_service.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final travelController = TravelController();
  File? imageFile;
  var uuid = const Uuid();
  bool _isLoading = false;
  String? currentTravelId;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
    });
  }

  void openCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  void openGallery() async {
    final imagePicker = ImagePicker();
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> addTravel({bool isEdit = false}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _formKey,
              child: AlertDialog(
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Input title",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please input title";
                        }
                        return null;
                      },
                    ),
                    const Gap(20),
                    const Text(
                      "Upload Image",
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                      ),
                    ),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.camera),
                          onPressed: openCamera,
                          label: const Text("Camera"),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.image),
                          onPressed: openGallery,
                          label: const Text("Gallery"),
                        ),
                      ],
                    ),
                    if (imageFile != null)
                      Container(
                        width: 250,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(imageFile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : FilledButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _isLoading = true;
                              });
                              String id = isEdit ? currentTravelId! : uuid.v4();
                              String locationString =
                                  LocationService.getLocationString();
                              if (isEdit) {
                                await travelController.updateTravel(
                                  id,
                                  _titleController.text,
                                  imageFile!,
                                  locationString,
                                );
                              } else {
                                await travelController.addTravel(
                                  id,
                                  _titleController.text,
                                  imageFile!,
                                  locationString,
                                );
                              }
                              setState(() {
                                _isLoading = false;
                                imageFile = null;
                              });
                              Navigator.of(context).pop();
                              _titleController.clear();
                            }
                          },
                          child: const Text('Save'),
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> editTravel(DocumentSnapshot travel) async {
    setState(() {
      _titleController.text = travel['title'];
      currentTravelId = travel['id'];
    });
    await addTravel(isEdit: true);
  }

  Future<void> deleteTravel(String travelId) async {
    await travelController.deleteTravel(travelId);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
          color: Colors.white,
        ),
        title: const Text(
          "Travel",
          style: TextStyle(
            fontFamily: 'Extrag',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.circle_notifications,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: travelController.list,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("Malumotlar topilmadi!"),
            );
          }

          final travelData = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 3 / 1.7,
              crossAxisSpacing: 20,
              mainAxisSpacing: 5,
            ),
            itemCount: travelData.length,
            itemBuilder: (context, index) {
              final data = travelData[index];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilledButton(
                            onPressed: () {
                              editTravel(data);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                            child: const Text('Edit'),
                          ),
                          FilledButton(
                            onPressed: () {
                              deleteTravel(data['id']);
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(data['photo']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Name: ${data['title']}",
                            style: const TextStyle(
                              fontFamily: "Extrag",
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            "Location: ${data['location']}",
                            style: const TextStyle(
                              fontFamily: "Extrag",
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        onPressed: addTravel,
        child: const Icon(Icons.add),
      ),
    );
  }
}
