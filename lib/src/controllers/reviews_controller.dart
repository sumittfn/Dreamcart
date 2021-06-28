import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/food.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/review.dart';
import '../repository/food_repository.dart' as foodRepo;
import '../repository/order_repository.dart';
import '../repository/restaurant_repository.dart' as restaurantRepo;

class ReviewsController extends ControllerMVC {
  Review restaurantReview;
  DriverReview driverReview;
  List<Review> foodsReviews = [];
  Order order;
  String driverName;
  List<Food> foodsOfOrder = [];
  List<OrderStatus> orderStatus = <OrderStatus>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  ReviewsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.restaurantReview = new Review.init("0");
    this.driverReview = new DriverReview.init("0");

  }

  void listenForOrder({String orderId, String message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
        driverName = _order.drivers;
        foodsReviews =
            List.generate(order.foodOrders.length, (_) => new Review.init("0"));
      });
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      getFoodsOfOrder();
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addFoodReview(Review _review, Food _food) async {
    foodRepo.addFoodReview(_review, _food).then((value) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_food_has_been_rated_successfully),
      ));
    });
  }

  void addRestaurantReview(Review _review) async {
    restaurantRepo
        .addRestaurantReview(_review, this.order.foodOrders[0].food.restaurant)
        .then((value) {
      refreshOrder();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_restaurant_has_been_rated_successfully),
      ));
    });
  }

  void addDriverReview(DriverReview _review) async {
    restaurantRepo.addDriverReview(_review, this.order.driver_id).then((value) {
      refreshOrder();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.the_delivery_boy_has_been_rated_successfully),
      ));
    });
  }

  Future<void> refreshOrder() async {
    listenForOrder(
        orderId: order.id, message: S.current.reviews_refreshed_successfully);
  }

  void getFoodsOfOrder() {
    this.order.foodOrders.forEach((_foodOrder) {
      if (!foodsOfOrder.contains(_foodOrder.food)) {
        foodsOfOrder.add(_foodOrder.food);
      }
    });
  }
}
