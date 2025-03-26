import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

// Events
abstract class CartEvent {}

class AddProductToCart extends CartEvent {
  final Product product;

  AddProductToCart(this.product);
}

class RemoveProductFromCart extends CartEvent {
  final int productId;

  RemoveProductFromCart(this.productId);
}

class IncrementProductQuantity extends CartEvent {
  final int productId;

  IncrementProductQuantity(this.productId);
}

class DecrementProductQuantity extends CartEvent {
  final int productId;

  DecrementProductQuantity(this.productId);
}

class ClearCart extends CartEvent {}

// States
abstract class CartState {
  List<CartItem> get items => [];
  double get totalAmount => 0;
}

class CartInitial extends CartState {
  @override
  List<CartItem> get items => [];
  
  @override
  double get totalAmount => 0;
}

class CartLoaded extends CartState {
  final List<CartItem> _items;

  CartLoaded(this._items);

  @override
  List<CartItem> get items => _items;
  
  @override
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final List<CartItem> _items = [];

  CartBloc() : super(CartInitial()) {
    on<AddProductToCart>(_onAddProductToCart);
    on<RemoveProductFromCart>(_onRemoveProductFromCart);
    on<IncrementProductQuantity>(_onIncrementProductQuantity);
    on<DecrementProductQuantity>(_onDecrementProductQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddProductToCart(
    AddProductToCart event,
    Emitter<CartState> emit,
  ) {
    final existingIndex = _items.indexWhere((item) => item.product.id == event.product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: event.product));
    }
    
    emit(CartLoaded(_items));
  }

  void _onRemoveProductFromCart(
    RemoveProductFromCart event,
    Emitter<CartState> emit,
  ) {
    _items.removeWhere((item) => item.product.id == event.productId);
    emit(CartLoaded(_items));
  }

  void _onIncrementProductQuantity(
    IncrementProductQuantity event,
    Emitter<CartState> emit,
  ) {
    final index = _items.indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      _items[index].quantity += 1;
      emit(CartLoaded(_items));
    }
  }

  void _onDecrementProductQuantity(
    DecrementProductQuantity event,
    Emitter<CartState> emit,
  ) {
    final index = _items.indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      emit(CartLoaded(_items));
    }
  }

  void _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) {
    _items.clear();
    emit(CartLoaded(_items));
  }
}