import 'package:location/location.dart';

class LocationService {
  static final _location = Location();

  static bool isServiceEnabled = false;
  static PermissionStatus permissionStatus = PermissionStatus.denied;
  static LocationData? currentLocation;

  static Future<void> init() async {
    await _checkSevice();
    await _checkPermission();
  }

  //! joylashuvni olish xizmati yoqilganmi tekshiramiz
  static Future<void> _checkSevice() async {
    isServiceEnabled = await _location.serviceEnabled();
    if (!isServiceEnabled) {
      _location.requestService();
      if (!isServiceEnabled) {
        return; // Redirect to Settings  - Sozlamalardan to'g'irlash kerak endi.
      }
    }
  }

  //! joylashuv olish uchun ruxsat berilganmi teshiramiz
  static Future<void> _checkPermission() async {
    permissionStatus = await _location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return; // Sozlamalardan to'g'irlash kerak (ruxsat berish kerak)
      }
    }
  }

  //! hozirgi joylashuvni olish
  static Future<void> getCurrentLocation() async {
    final location = Location();
    isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) return;
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) return;
    }

    currentLocation = await location.getLocation();
  }

  static String getLocationString() {
    if (currentLocation == null) return 'Unknown location';
    return '${currentLocation!.latitude}, ${currentLocation!.longitude}';
  }
}
