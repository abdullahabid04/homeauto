import '../utils/custom_exception.dart';
import '../utils/network_util.dart';

class ManufacturedProducts {
  int? status;
  String? message;
  List<Products>? products;

  ManufacturedProducts({this.status, this.message, this.products});

  ManufacturedProducts.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Products {
  String? id;
  String? deviceName;
  String? deviceType;
  String? deviceSpecs;
  String? deviceBtName;
  String? deviceDesc;
  String? deviceImage;

  Products(
      {this.id,
      this.deviceName,
      this.deviceType,
      this.deviceSpecs,
      this.deviceBtName,
      this.deviceDesc,
      this.deviceImage});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceName = json['device_name'];
    deviceType = json['device_type'];
    deviceSpecs = json['device_specs'];
    deviceBtName = json['device_bt_name'];
    deviceDesc = json['device_desc'];
    deviceImage = json['device_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_name'] = this.deviceName;
    data['device_type'] = this.deviceType;
    data['device_specs'] = this.deviceSpecs;
    data['device_bt_name'] = this.deviceBtName;
    data['device_desc'] = this.deviceDesc;
    data['device_image'] = this.deviceImage;
    return data;
  }
}

class RequestProducts {
  NetworkUtil _netUtil = new NetworkUtil();
  static const baseURL = 'http://care-engg.com/api/company';
  static const productsURL = baseURL + '/products';

  Future<ManufacturedProducts> getPrducts() async {
    return _netUtil.get(productsURL).then((dynamic res) {
      print(res.toString());
      if (res["status"] == 0) throw new FormException(res["message"]);
      return ManufacturedProducts.fromJson(res);
    });
  }
}

abstract class ManufacturedProductsContracor {
  void onProductsSuccess(List<Products>? products);
  void onProductsError(String error);
}

class ManufacturedProductsPresenter {
  ManufacturedProductsContracor _contracor;
  RequestProducts api = new RequestProducts();
  ManufacturedProductsPresenter(this._contracor);

  doGetProducts() async {
    try {
      ManufacturedProducts data = await api.getPrducts();
      if (data == null) {
        _contracor.onProductsError("Update Failed");
      } else {
        _contracor.onProductsSuccess(data.products);
      }
    } on Exception catch (error) {
      _contracor.onProductsError(error.toString());
    }
  }
}
