import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'detector_painters.dart';
import 'utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';

import 'welcome_page.dart';

class FaceScanScreen extends StatefulWidget {
  final bool login;
  final String? name;
  const FaceScanScreen({Key? key, required this.login, this.name})
      : super(key: key);

  @override
  _FaceScanScreenState createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory? tempDir;
  List? e1;
  bool _faceFound = false;
  final TextEditingController _name = TextEditingController();
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
  }

  bool detected = false;
  void _initializeCamera() async {
    CameraDescription description = await getCamera(_direction);

    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(description, ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);

    await _camera!.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    File(_embPath).createSync();
    jsonFile = File(_embPath);
    if (jsonFile!.existsSync() && jsonFile!.readAsStringSync() != '')
      data = json.decode(jsonFile!.readAsStringSync());
    else
      data = {};
    setState(() {});
    _camera!.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting || detected) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (detected) {
              return;
            }
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            setState(() {
              _scanResults = finalResult;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            _isDetecting = false;
          },
        );
      }
    });
  }

  _getDetectionMethod() {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera!),
                // _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera!.stopImageStream();
    await _camera!.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    // if (mounted) {
    _camera!.stopImageStream();
    _camera!.dispose();
    super.dispose();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face recognition'),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: (Choice result) {
              if (result == Choice.delete)
                _resetFile();
              else
                _viewLabels();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Choice>>[
              const PopupMenuItem<Choice>(
                child: Text('View Saved Faces'),
                value: Choice.view,
              ),
              const PopupMenuItem<Choice>(
                child: Text('Remove all faces'),
                value: Choice.delete,
              )
            ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (!widget.login)
          FloatingActionButton(
            backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
            child: Icon(Icons.add),
            onPressed: () {
              if (_faceFound) _addLabel();
            },
            heroTag: null,
          ),
        SizedBox(
          height: 10,
        ),
      ]),
    );
  }

  void _resetFile() {
    data = {};
    jsonFile!.deleteSync();
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String name;
    var alert = AlertDialog(
      title: Text("Saved Faces"),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width * 0.5,
        child: ListView.builder(
            padding: EdgeInsets.all(2),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              name = data.keys.elementAt(index);
              return new ListTile(
                title: new Text(
                  name,
                  style: new TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              );
            }),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert = AlertDialog(
      title: Text("Add Face"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _name,
              autofocus: true,
              decoration:
                  InputDecoration(labelText: "Name", icon: Icon(Icons.face)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
            child: Text("Save"),
            onPressed: () {
              _handle(_name.text.toUpperCase());
              _name.clear();
              Navigator.pop(context);
            }),
        ElevatedButton(
          child: Text("Cancel"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _handle(String text) {
    data[text] = e1;
    jsonFile!.writeAsStringSync(json.encode(data));
    _initializeCamera();
  }
}
