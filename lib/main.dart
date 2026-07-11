import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codeacademy/data/local/secure_storage.dart';
import 'package:codeacademy/data/remote/api/dio_client.dart';
import 'package:codeacademy/data/repository/auth_repository_impl.dart';
import 'package:codeacademy/data/repository/catalog_repository_impl.dart';
import 'package:codeacademy/data/repository/order_repository_impl.dart';
import 'package:codeacademy/data/repository/admin_repository_impl.dart';
import 'package:codeacademy/presentation/navigation/app_router.dart';
import 'package:codeacademy/presentation/providers/auth_provider.dart';
import 'package:codeacademy/presentation/providers/catalog_provider.dart';
import 'package:codeacademy/presentation/providers/cart_provider.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/presentation/providers/admin_provider.dart';
import 'package:codeacademy/presentation/providers/teacher_provider.dart';
import 'package:codeacademy/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SecureStorage _secureStorage;
  late final DioClient _dioClient;
  late final AuthRepositoryImpl _authRepository;
  late final CatalogRepositoryImpl _catalogRepository;
  late final OrderRepositoryImpl _orderRepository;
  late final AdminRepositoryImpl _adminRepository;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _secureStorage = SecureStorage();
    _dioClient = DioClient(
      secureStorage: _secureStorage,
      onAuthExpired: () {
        _authProvider.forceLogout();
      },
    );
    final dio = _dioClient.dio;
    _authRepository = AuthRepositoryImpl(dio: dio, secureStorage: _secureStorage);
    _catalogRepository = CatalogRepositoryImpl(dio: dio);
    _orderRepository = OrderRepositoryImpl(dio: dio);
    _adminRepository = AdminRepositoryImpl(dio: dio);
    
    _authProvider = AuthProvider(authRepository: _authRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<CatalogProvider>(
          create: (_) => CatalogProvider(catalogRepository: _catalogRepository),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(orderRepository: _orderRepository),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(orderRepository: _orderRepository),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(
            catalogRepository: _catalogRepository,
            adminRepository: _adminRepository,
            orderRepository: _orderRepository,
          ),
        ),
        ChangeNotifierProvider<TeacherProvider>(
          create: (_) => TeacherProvider(
            catalogRepository: _catalogRepository,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          return MaterialApp.router(
            title: 'CodeAcademy',
            theme: AppTheme.darkTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
