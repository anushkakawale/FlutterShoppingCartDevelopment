import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product.dart';
import '../services/product_service.dart';

// Events
abstract class ProductEvent {}

class FetchProducts extends ProductEvent {
  final int limit;
  final int skip;

  FetchProducts({this.limit = 10, this.skip = 0});
}

// States
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final List<Product>? products;
  
  ProductLoading({this.products});
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasReachedMax;

  ProductLoaded({
    required this.products,
    this.hasReachedMax = false,
  });
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService = ProductService();

  ProductBloc() : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      if (state is ProductInitial) {
        emit(ProductLoading());
        final products = await _productService.getProducts(
          limit: event.limit,
          skip: event.skip,
        );
        emit(ProductLoaded(
          products: products,
          hasReachedMax: products.length < event.limit,
        ));
        return;
      }

      if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        
        if (currentState.hasReachedMax) return;
        
        emit(ProductLoading(products: currentState.products));
        
        final products = await _productService.getProducts(
          limit: event.limit,
          skip: currentState.products.length,
        );
        
        emit(
          products.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : ProductLoaded(
                  products: [...currentState.products, ...products],
                  hasReachedMax: products.length < event.limit,
                ),
        );
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

extension on ProductLoaded {
  ProductLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}