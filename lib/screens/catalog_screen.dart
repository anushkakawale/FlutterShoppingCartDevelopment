import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/product_bloc.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductBloc>().add(FetchProducts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(FetchProducts(skip: _getCurrentProductCount()));
    }
  }

  int _getCurrentProductCount() {
    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      return state.products.length;
    }
    return 0;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        title: const Text(
          'Catalogue',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.black87),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (state.items.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${state.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductInitial) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(FetchProducts());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          List<Product> products = [];
          bool isLoading = false;
          bool hasReachedMax = false;

          if (state is ProductLoaded) {
            products = state.products;
            hasReachedMax = state.hasReachedMax;
          } else if (state is ProductLoading) {
            products = state.products ?? [];
            isLoading = true;
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: hasReachedMax
                ? products.length
                : products.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));
              }
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}