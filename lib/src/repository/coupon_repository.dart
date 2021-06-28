import 'dart:convert';

import 'package:Dreamcart/src/models/coupon.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Coupon>> verifyCoupon(String code) async {
  Uri uri = Helper.getUri('api/coupons');
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  // Map<String, dynamic> query = {
  //   'api_token': _user.apiToken,
  //   'with': 'discountables',
  //   'search': 'code:$code',
  //   'searchFields': 'code:=',
  // };
  // uri = uri.replace(queryParameters: query);
  // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Coupon.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Coupon.fromJSON({}));
  }
}

Future<Coupon> saveCoupon(Coupon coupon) async {
  if (coupon != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('coupon', json.encode(coupon.toMap()));
  }
  return coupon;
}

Future<Stream<Coupon>> getCoupon(String restaurant_id) async {
  // Uri uri = Helper.getUri('api/coupons');
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}coupons?restaurant_id=$restaurant_id';
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }


  // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    print("CouponList API :::::::::::>>>>> " + url.toString());
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {

          print("Coupon Data ::::::::::::::::::::::::>>>>>>>>>>>>>>> " + data.toString());
      return Coupon.fromJSON(data);
    });
  } catch (e) {}

  // Coupon _coupon = Coupon.fromJSON({});

  return new Stream.value(new Coupon.fromJSON({}));
}
