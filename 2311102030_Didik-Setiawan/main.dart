import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	List<CameraDescription> cameras = <CameraDescription>[];
	try {
		cameras = await availableCameras();
	} on CameraException {
		// If camera discovery fails, gallery flow still works.
		cameras = <CameraDescription>[];
	}

	await LocalNotificationService.instance.init();
	runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
	const MyApp({super.key, required this.cameras});

	final List<CameraDescription> cameras;

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'Modul 8-9',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
				useMaterial3: true,
			),
			home: HomePage(cameras: cameras),
		);
	}
}

class HomePage extends StatefulWidget {
	const HomePage({super.key, required this.cameras});

	final List<CameraDescription> cameras;

	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	final ImagePicker _picker = ImagePicker();
	Uint8List? _selectedImageBytes;

	Future<void> _pickFromGallery() async {
		try {
			final XFile? file = await _picker.pickImage(
				source: ImageSource.gallery,
				imageQuality: 90,
			);
			if (file == null) {
				return;
			}
			await _setImageAndNotify(file);
		} catch (e) {
			_showSnackBar('Gagal memilih foto dari galeri: $e');
		}
	}

	Future<void> _captureWithCamera() async {
		if (widget.cameras.isEmpty) {
			_showSnackBar('Kamera tidak tersedia di perangkat ini.');
			return;
		}

		final XFile? result = await Navigator.of(context).push<XFile>(
			MaterialPageRoute<XFile>(
				builder: (_) => CameraCapturePage(cameras: widget.cameras),
			),
		);

		if (result == null) {
			return;
		}

		await _setImageAndNotify(result);
	}

	Future<void> _setImageAndNotify(XFile file) async {
		final Uint8List bytes = await file.readAsBytes();
		if (!mounted) {
			return;
		}

		setState(() {
			_selectedImageBytes = bytes;
		});

		await LocalNotificationService.instance.showPhotoSuccessNotification();
	}

	void _showSnackBar(String message) {
		if (!mounted) {
			return;
		}
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message)),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Tugas Praktikum Modul 8-9'),
			),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: <Widget>[
						Row(
							children: <Widget>[
								Expanded(
									child: ElevatedButton.icon(
										onPressed: _captureWithCamera,
										icon: const Icon(Icons.camera_alt_outlined),
										label: const Text('Buka Kamera'),
									),
								),
								const SizedBox(width: 12),
								Expanded(
									child: ElevatedButton.icon(
										onPressed: _pickFromGallery,
										icon: const Icon(Icons.photo_library_outlined),
										label: const Text('Pilih Galeri'),
									),
								),
							],
						),
						const SizedBox(height: 20),
						Expanded(
							child: DecoratedBox(
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(12),
									border: Border.all(color: Colors.teal.shade200),
								),
								child: Center(
									child: _selectedImageBytes == null
											? const Text(
													'Belum ada foto.\nAmbil dari kamera atau galeri.',
													textAlign: TextAlign.center,
												)
											: ClipRRect(
													borderRadius: BorderRadius.circular(12),
													child: Image.memory(
														_selectedImageBytes!,
														fit: BoxFit.contain,
														width: double.infinity,
													),
												),
								),
							),
						),
					],
				),
			),
		);
	}
}

class CameraCapturePage extends StatefulWidget {
	const CameraCapturePage({super.key, required this.cameras});

	final List<CameraDescription> cameras;

	@override
	State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
	late final CameraController _cameraController;
	late final Future<void> _initializeControllerFuture;

	@override
	void initState() {
		super.initState();
		final CameraDescription selectedCamera = widget.cameras.firstWhere(
			(CameraDescription camera) =>
					camera.lensDirection == CameraLensDirection.back,
			orElse: () => widget.cameras.first,
		);

		_cameraController = CameraController(
			selectedCamera,
			ResolutionPreset.medium,
			enableAudio: false,
		);
		_initializeControllerFuture = _cameraController.initialize();
	}

	@override
	void dispose() {
		_cameraController.dispose();
		super.dispose();
	}

	Future<void> _takePicture() async {
		try {
			await _initializeControllerFuture;
			final XFile file = await _cameraController.takePicture();
			if (!mounted) {
				return;
			}
			Navigator.of(context).pop(file);
		} catch (e) {
			if (!mounted) {
				return;
			}
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Gagal mengambil foto: $e')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Kamera')),
			body: FutureBuilder<void>(
				future: _initializeControllerFuture,
				builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
					if (snapshot.connectionState == ConnectionState.done) {
						return CameraPreview(_cameraController);
					}
					if (snapshot.hasError) {
						return Center(
							child: Text('Tidak dapat mengakses kamera: ${snapshot.error}'),
						);
					}
					return const Center(child: CircularProgressIndicator());
				},
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _takePicture,
				child: const Icon(Icons.camera),
			),
		);
	}
}

class LocalNotificationService {
	LocalNotificationService._();

	static final LocalNotificationService instance = LocalNotificationService._();
	final FlutterLocalNotificationsPlugin _plugin =
			FlutterLocalNotificationsPlugin();

	bool _initialized = false;

	Future<void> init() async {
		if (_initialized) {
			return;
		}

		const AndroidInitializationSettings androidSettings =
				AndroidInitializationSettings('@mipmap/ic_launcher');
		const DarwinInitializationSettings darwinSettings =
				DarwinInitializationSettings();

		const InitializationSettings settings = InitializationSettings(
			android: androidSettings,
			iOS: darwinSettings,
		);

		await _plugin.initialize(settings);

		final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
				_plugin.resolvePlatformSpecificImplementation<
						AndroidFlutterLocalNotificationsPlugin>();
		await androidImplementation?.requestNotificationsPermission();

		final IOSFlutterLocalNotificationsPlugin? iosImplementation =
				_plugin.resolvePlatformSpecificImplementation<
						IOSFlutterLocalNotificationsPlugin>();
		await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);

		_initialized = true;
	}

	Future<void> showPhotoSuccessNotification() async {
		const AndroidNotificationDetails androidDetails =
				AndroidNotificationDetails(
			'photo_channel',
			'Photo Notifications',
			channelDescription: 'Notifikasi saat foto berhasil dipilih/diambil',
			importance: Importance.high,
			priority: Priority.high,
		);

		const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

		const NotificationDetails details = NotificationDetails(
			android: androidDetails,
			iOS: darwinDetails,
		);

		await _plugin.show(
			DateTime.now().millisecondsSinceEpoch ~/ 1000,
			'Foto Berhasil',
			'Foto sudah siap ditampilkan di halaman utama.',
			details,
		);
	}
}
