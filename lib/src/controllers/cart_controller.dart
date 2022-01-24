import 'package:get/get.dart';
import 'package:githubit/src/components/error_dialog.dart';
import 'package:githubit/src/controllers/currency_controller.dart';
import 'package:githubit/src/controllers/order_controller.dart';
import 'package:githubit/src/controllers/shop_controller.dart';
import 'package:githubit/src/models/address.dart';
import 'package:githubit/src/models/card.dart';
import 'package:githubit/src/models/product.dart';
import 'package:githubit/src/models/shop.dart';
import 'package:githubit/src/models/user.dart';
import 'package:githubit/src/requests/check_cart_request.dart';
import 'package:githubit/src/requests/order_save_request.dart';
import 'package:githubit/src/requests/payment_request.dart';
import 'package:githubit/src/requests/shipping_detail_request.dart';

class CartController extends GetxController {
  final ShopController shopController = Get.put(ShopController());
  final CurrencyController currencyController = Get.put(CurrencyController());
  final OrderController orderController = Get.put(OrderController());
  var cartProducts = <Product>[].obs;
  Shop? shop;
  var deliveryType = 1.obs;
  var deliveryTransport = 0.obs;
  var deliveryTransportList = [].obs;
  var deliveryPlan = 0.obs;
  var deliveryPlanList = [].obs;
  var deliveryBoxType = 0.obs;
  var deliveryBoxTypeList = [].obs;
  var proccess = 0.obs;
  var proccessPercentage = 0.obs;
  var cardName = "".obs;
  var cardNumber = "".obs;
  var cardExpiredDate = "".obs;
  var cvc = "".obs;
  var orderSent = false.obs;
  var paymentType = 1.obs;
  var paymentStatus = 1.obs;
  var orderComment = "".obs;
  var cards = <Card>[].obs;
  var activeCardNumber = "".obs;
  var isCardAvailable = false.obs;
  var paymentEmail = "".obs;
  var orderId = 0.obs;
  var paymentUrl = "".obs;

  @override
  void dispose() {
    super.dispose();
  }

  void addToCart(Product product) {
    product.count = 1;
    int index = cartProducts.indexWhere((element) => element.id == product.id);
    if (index == -1) cartProducts.add(product);
    cartProducts.refresh();
  }

  void increment(id) {
    int index = cartProducts.indexWhere((element) => element.id == id);
    if (index > -1) {
      cartProducts[index].count = cartProducts[index].count! + 1;
      cartProducts.refresh();
    }
  }

  void decrement(id) {
    int index = cartProducts.indexWhere((element) => element.id == id);
    if (index > -1) {
      if (cartProducts[index].count! > 1)
        cartProducts[index].count = cartProducts[index].count! - 1;
      else
        cartProducts.removeAt(index);
      cartProducts.refresh();
    }
  }

  int getProductCountById(int id) {
    int index = cartProducts.indexWhere((element) => element.id == id);
    if (index > -1) {
      return cartProducts[index].count!;
    }
    return 0;
  }

  void removeProductFromCart(int id) {
    int index = cartProducts.indexWhere((element) => element.id == id);
    if (index > -1) {
      cartProducts.removeAt(index);
      cartProducts.refresh();
    }
  }

  double calculateAmount() {
    double sum = 0;

    for (Product product in cartProducts) {
      double extrasSum = product.extras != null
          ? product.extras!.fold(0, (a, b) => a + b.price!)
          : 0;
      sum += product.count! * (product.price! + extrasSum);
    }

    return double.parse(sum.toStringAsFixed(2));
  }

  double calculateTaxAmount() {
    shop = shopController.defaultShop.value;
    double tax = 0;
    double sum = 0;

    for (Product product in cartProducts) {
      double extrasSum = product.extras != null
          ? product.extras!.fold(0, (a, b) => a + b.price!)
          : 0;
      tax += (product.count! * (product.price! + extrasSum)) *
          (product.tax! / 100);
      sum += product.count! * (product.price! + extrasSum);
    }
    tax += sum * (shop!.tax! / 100);

    return double.parse(tax.toStringAsFixed(2));
  }

  double calculateDiscount() {
    double sum = 0;

    for (Product product in cartProducts) {
      double discountPrice = 0;
      if (product.discountType == 1)
        discountPrice = (product.price! * product.discount!) / 100;
      else if (product.discountType == 2) discountPrice = product.discount!;
      sum += (product.count! * discountPrice);
    }

    return double.parse(sum.toStringAsFixed(2));
  }

  double calculateDeliveryFee() {
    double sum = 0;

    int index = deliveryPlanList
        .indexWhere((element) => element['id'] == deliveryPlan.value);
    if (index > -1) {
      sum += double.parse("${deliveryPlanList[index]['amount']}");
    }

    int index2 = deliveryTransportList
        .indexWhere((element) => element['id'] == deliveryTransport.value);
    if (index2 > -1) {
      sum += double.parse("${deliveryTransportList[index2]['price']}");
    }

    int index3 = deliveryBoxTypeList
        .indexWhere((element) => element['id'] == deliveryBoxType.value);
    if (index3 > -1) {
      sum += double.parse("${deliveryBoxTypeList[index3]['price']}");
    }

    return double.parse(sum.toStringAsFixed(2));
  }

  void checkoutData() {
    shop = shopController.defaultShop.value;
    User? user = shopController.authController.user.value;
    Address address = shopController.addressController.getDefaultAddress();

    proccessPercentage.value = 0;
    if (deliveryType.value > 0) proccessPercentage.value += 10;

    if (address.address != null && address.address!.length > 0)
      proccessPercentage.value += 12;

    if (user != null && user.name != null && user.name!.length > 0)
      proccessPercentage.value += 12;

    if (user != null && user.phone != null && user.phone!.length > 0)
      proccessPercentage.value += 12;

    if (proccess.value >= 1) proccessPercentage.value += 4;
  }

  Future<void> orderSave() async {
    orderSent.value = true;
    shop = shopController.defaultShop.value;
    Address address = shopController.addressController.getDefaultAddress();
    User? user = shopController.authController.getUser();

    Map<String, dynamic> body = {
      "total_amount": (calculateAmount() -
              calculateDiscount() +
              calculateTaxAmount() +
              (shopController.deliveryType.value == 1
                  ? calculateDeliveryFee()
                  : 0))
          .toStringAsFixed(2),
      "total_discount": calculateDiscount(),
      "tax": calculateTaxAmount(),
      "delivery_type": shopController.deliveryType.value,
      "delivery_fee":
          (shopController.deliveryType.value == 1 ? calculateDeliveryFee() : 0),
      "delivery_date":
          "${shopController.deliveryDate.value} ${shopController.deliveryTimeString.value}",
      "delivery_time_id": shopController.deliveryTime.value.toString(),
      "payment_type": paymentType.value.toString(),
      "payment_status": paymentStatus.value.toString(),
      "product_details": cartProducts.map((element) {
        if (element.count! > 0)
          return {"id": element.id, "quantity": element.count};
        else
          return null;
      }).toList(),
      "address": address.toJson(),
      "user": user!.id.toString(),
      "shop": shop!.id.toString(),
      "comment": orderComment.value.toString(),
      "type": shopController.deliveryType.value.toString(),
      "delivery_type_id": deliveryPlan.value.toString(),
      "delivery_transport_id": deliveryTransport.value.toString(),
      "shipping_box_id": deliveryBoxType.value.toString()
    };

    Map<String, dynamic> data = await orderSaveRequest(body);

    if (data['success']) {
      orderSent.value = false;

      if (data['data']['missed_products'] != null &&
          data['data']['missed_products'].length > 0) {
        Get.bottomSheet(ErrorAlert(
          message: "Some products are not enough in stock".tr,
        ));
      } else {
        cartProducts.value = [];
        proccess.value = 0;
        orderId.value = data['data']['id'];
        Map<String, dynamic> paymentData = await paymentRequest(
            shop!.id!,
            data['data']['id'],
            paymentType.value,
            paymentEmail.value,
            cardNumber.value,
            cardExpiredDate.value,
            cardName.value,
            cvc.value);
        if (paymentData['success']) {}
        Get.toNamed("/orderSuccess");
      }
    }
  }

  void addToCard() {
    Card card = Card(
      name: cardName.value,
      cardNumber: cardNumber.value,
      expireDate: cardExpiredDate.value,
      cvc: cvc.value,
    );

    int index =
        cards.indexWhere((element) => element.cardNumber == cardNumber.value);
    if (index == -1)
      cards.add(card);
    else
      cards[index] = card;
    cards.refresh();
    Get.back();
  }

  Future<void> getShippingDetail() async {
    shop = shopController.defaultShop.value;
    Map<String, dynamic> data = await shippingDetailRequest(shop!.id!);

    if (data != null && data['success'] != null) {
      deliveryPlanList.value = data['data']['shop_delivery_types'];
      deliveryTransportList.value = data['data']['shop_delivery_transports'];
      deliveryBoxTypeList.value = data['data']['shop_delivery_boxes'];
    }
  }

  Future<void> checkCard() async {
    List products = [];

    for (int i = 0; i < cartProducts.length; i++) {
      products.add(cartProducts[i].id);
    }

    Map<String, dynamic> data = await checkCartRequest(products);

    if (data['data'] != null)
      for (int i = 0; i < data['data'].length; i++) {
        int id = data['data'][i]['id'];
        int quantity = data['data'][i]['quantity'];

        int index = cartProducts.indexWhere((element) => element.id == id);
        if (index != -1) {
          if (quantity <= 0) {
            cartProducts.removeAt(index);
          } else if (cartProducts[index].count! > quantity) {
            cartProducts[index].count = quantity;
          }
        }
      }

    cartProducts.refresh();
  }
}
