import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../viewmodels/upload_viewmodel.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;
  LatLng? _userPosition;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();
    if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });

    Provider.of<UploadViewModel>(context, listen: false).setLocation(_userPosition!);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userPosition!, 15)); //Harita açıldığında kamera otomatik olarak kullanıcının konumuna zoom yapar.
  }

  Future<void> _pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (picked != null) {
      Provider.of<UploadViewModel>(context, listen: false).setFile(File(picked.path), video: false);
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      final file = File(picked.path);
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration;

      if (duration.inSeconds > 20) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Video Süresi Çok Uzun"),
              content: const Text("Lütfen en fazla 20 saniyelik bir video seçin."),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam")),
              ],
            ),
          );
        }
        return;
      }

      Provider.of<UploadViewModel>(context, listen: false).setFile(file, video: true);
    }
  }

  Future<void> _pickVideoFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 20));
    if (picked != null) {
      Provider.of<UploadViewModel>(context, listen: false).setFile(File(picked.path), video: true);
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kameradan Fotoğraf"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Galeriden Fotoğraf"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text("Kameradan Video"),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text("Galeriden Video"),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadVM = Provider.of<UploadViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginView()),
            );
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_boat_filled, color: Colors.white),
            SizedBox(width: 8),
            Text("Ship Detection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: GoogleMap(  //UI'da harita
                    initialCameraPosition: CameraPosition(target: _userPosition!, zoom: 15), //ne kadar zoom
                    myLocationEnabled: true, //Cihazın gerçek konumunu mavi nokta olarak gösterir
                    onMapCreated: (controller) => _mapController = controller,
                    markers: {
                      Marker(
                        markerId: const MarkerId("konum"),
                        position: _userPosition!,
                        infoWindow: const InfoWindow(title: "Senin Konumun"),
                      )
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, height: 1),
                const SizedBox(height: 10),

                if (uploadVM.selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Dosya: ${uploadVM.selectedFile!.path.split('/').last}",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _customButton(
                        icon: Icons.photo_camera,
                        text: "Fotoğraf",
                        onPressed: _showImageSourcePicker,
                      ),
                      _customButton(
                        icon: Icons.videocam,
                        text: "Video",
                        onPressed: _showVideoSourcePicker,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: uploadVM.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              await uploadVM.predict(); //tahmin et butonuna basınca 
                              if (uploadVM.result != null) {
                                final confidence = uploadVM.confidence ?? 0.0;
                                final resultClass = uploadVM.result;

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(confidence < 0.3 ? "Düşük Güvenli Tahmin" : "Tahmin Sonucu"),
                                    content: Text(
                                      "Sınıf: $resultClass\n"
                                      "Güven: ${(confidence * 100).toStringAsFixed(1)}%\n"
                                      "Konum: ${_userPosition!.latitude.toStringAsFixed(5)}, ${_userPosition!.longitude.toStringAsFixed(5)}",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Tamam"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text("Tahmin Et", style: TextStyle(fontSize: 18)),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _customButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
