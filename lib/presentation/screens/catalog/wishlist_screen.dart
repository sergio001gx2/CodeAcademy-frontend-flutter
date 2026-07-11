import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:codeacademy/presentation/providers/order_provider.dart';
import 'package:codeacademy/presentation/widgets/loading_overlay.dart';
import 'package:codeacademy/theme/app_colors.dart';
import 'package:codeacademy/theme/app_text_styles.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;Provider.of<OrderProvider>(context, listen: false).loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Lista de Deseos'),
      ),
      body: LoadingOverlay(
        isLoading: orderProvider.isLoading,
        child: orderProvider.wishlist.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'Tu lista de deseos está vacía',
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orderProvider.wishlist.length,
                itemBuilder: (context, index) {
                  final item = orderProvider.wishlist[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        item.courseTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text('Guardado en favoritos', style: TextStyle(color: AppColors.textSecondary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryLight),
                            onPressed: () {
                              context.push('/course/${item.course}');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: AppColors.error),
                            onPressed: () async {
                              await orderProvider.removeFromWishlist(item.course);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removido de la lista de deseos'),
                                    backgroundColor: AppColors.info,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
