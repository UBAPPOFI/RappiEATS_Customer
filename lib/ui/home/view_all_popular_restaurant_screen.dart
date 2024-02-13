import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rappieats_customer/AppGlobal.dart';
import 'package:rappieats_customer/main.dart';
import 'package:rappieats_customer/model/VendorModel.dart';
import 'package:rappieats_customer/services/FirebaseHelper.dart';
import 'package:rappieats_customer/services/helper.dart';
import 'package:rappieats_customer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:rappieats_customer/ui/vendorProductsScreen/newVendorProductsScreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants.dart';

class ViewAllPopularRestaurantScreen extends StatefulWidget {
  const ViewAllPopularRestaurantScreen({Key? key, this.isPageCallForDineIn = false}) : super(key: key);

  @override
  _ViewAllPopularRestaurantScreenState createState() => _ViewAllPopularRestaurantScreenState();

  final bool? isPageCallForDineIn;
}

class _ViewAllPopularRestaurantScreenState extends State<ViewAllPopularRestaurantScreen> {
  Stream<List<VendorModel>>? vendorsFuture;
  final fireStoreUtils = FireStoreUtils();
  List<VendorModel> storeAllLst = [];

  // List<VendorModel> popularStoreLst = [];
  var position = const LatLng(23.12, 70.22);
  bool showLoader = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    fireStoreUtils.getRestaurantNearBy().whenComplete(() {
      vendorsFuture = fireStoreUtils.getAllRestaurants(path: widget.isPageCallForDineIn == true ? "isDineIn" : "").asBroadcastStream();

      vendorsFuture!.listen((value) {
        storeAllLst.clear();
        storeAllLst.addAll(value);
        List<VendorModel> temp5 = storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 5).toList();
        List<VendorModel> temp5_ =
            storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 4 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 5).toList();
        List<VendorModel> temp4 =
            storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 3 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 4).toList();
        List<VendorModel> temp3 =
            storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 2 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 3).toList();
        List<VendorModel> temp2 =
            storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) > 1 && num.parse((element.reviewsSum / element.reviewsCount).toString()) < 2).toList();
        List<VendorModel> temp1 = storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 1).toList();
        List<VendorModel> temp0 = storeAllLst.where((element) => num.parse((element.reviewsSum / element.reviewsCount).toString()) == 0).toList();
        List<VendorModel> temp0_ = storeAllLst.where((element) => element.reviewsSum == 0 && element.reviewsCount == 0).toList();

        storeAllLst.clear();
        storeAllLst.addAll(temp5);
        storeAllLst.addAll(temp5_);
        storeAllLst.addAll(temp4);
        storeAllLst.addAll(temp3);
        storeAllLst.addAll(temp2);
        storeAllLst.addAll(temp1);
        storeAllLst.addAll(temp0);
        storeAllLst.addAll(temp0_);
        setState(() {
          showLoader = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppGlobal.buildAppBar(context, "Most Popular".tr()),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: showLoader
                ? Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                    ),
                  )
                : storeAllLst.isEmpty
                    ? showEmptyState('No Items'.tr(), context)
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        itemCount: storeAllLst.length,
                        itemBuilder: (context, index) => buildPopularsItem(storeAllLst[index]))));
  }

  Widget buildPopularsItem(VendorModel vendorModel) {
    return GestureDetector(
      onTap: () {
        if (widget.isPageCallForDineIn == true) {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        } else {
          push(
            context,
            NewVendorProductsScreen(vendorModel: vendorModel),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 260,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 0.1),
            boxShadow: [
              isDarkMode(context)
                  ? const BoxShadow()
                  : BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8.0,
                      spreadRadius: 1.2,
                      offset: const Offset(0.2, 0.2),
                    ),
            ],
            color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: getImageVAlidUrl(vendorModel.photo),
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
              )),
              errorWidget: (context, url, error) => ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    AppGlobal.placeHolderImage!,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  )),
              fit: BoxFit.cover,
            )),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(vendorModel.title,
                            maxLines: 1,
                            style: const TextStyle(
                              fontFamily: "Poppinsm",
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff000000),
                            )).tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                const SizedBox(width: 3),
                                Text(vendorModel.reviewsCount != 0 ? (vendorModel.reviewsSum / vendorModel.reviewsCount).toStringAsFixed(1) : 0.toString(),
                                    style: const TextStyle(
                                      fontFamily: "Poppinsm",
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff666666),
                                    )),
                                const SizedBox(width: 3),
                                Text("(${vendorModel.reviewsCount})",
                                    style: const TextStyle(
                                      fontFamily: "Poppinsm",
                                      letterSpacing: 0.5,
                                      color: Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const ImageIcon(
                        AssetImage('assets/images/location3x.png'),
                        size: 15,
                        color: Color(0xff555353),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Text(vendorModel.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: "Poppinsm",
                                letterSpacing: 0.5,
                                color: Color(0xff555353),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff555353),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Text(getKm(vendorModel.latitude, vendorModel.longitude)! + " km",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Poppinsm",
                                    color: Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getUserLocation() async {
    //   var positions = await GeolocatorPlatform.instance
    //      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      position = LatLng(MyAppState.selectedPosotion.location!.latitude, MyAppState.selectedPosotion.location!.longitude);
      // cameraPosition = CameraPosition(
      //   target: LatLng(position.latitude, position.longitude),
      //   zoom: 14.4746,
      // );
    });
  }

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(latitude, longitude, position.latitude, position.longitude);
    double kilometer = distanceInMeters / 1000;

    return kilometer.toStringAsFixed(currencyModel!.decimal).toString();
  }
}
