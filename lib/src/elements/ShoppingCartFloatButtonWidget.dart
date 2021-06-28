import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cart_controller.dart';
import '../models/food.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ShoppingCartFloatButtonWidget extends StatefulWidget {
  const ShoppingCartFloatButtonWidget({
    this.iconColor,
    this.labelColor,
    this.food,
    this.city_id,
    Key key, this.city,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;
  final Food food;
  final String city_id;
  final String city;

  @override
  _ShoppingCartFloatButtonWidgetState createState() =>
      _ShoppingCartFloatButtonWidgetState();
}

class _ShoppingCartFloatButtonWidgetState
    extends StateMVC<ShoppingCartFloatButtonWidget> {
  CartController _con;

  _ShoppingCartFloatButtonWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: RaisedButton(
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
        shape: StadiumBorder(),
        onPressed: () {
          if (currentUser.value.apiToken != null) {
            Navigator.of(context).pushNamed('/Cart',
                arguments: RouteArgument(param: '/Food', id: widget.food.id,city_id: widget.city_id,city: widget.city));
          } else {
            Navigator.of(context).pushNamed('/Login');
          }
        },
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            Icon(
              Icons.shopping_cart,
              color: this.widget.iconColor,
              size: 28,
            ),
            Container(
              child: Text(
                _con.cartCount.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.caption.merge(
                      TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 9),
                    ),
              ),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: this.widget.labelColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              constraints: BoxConstraints(
                  minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
            ),
          ],
        ),
      ),
    );
//    return FlatButton(
//      onPressed: () {
//        print('to shopping cart');
//      },
//      child:
//      color: Colors.transparent,
//    );
  }
}
