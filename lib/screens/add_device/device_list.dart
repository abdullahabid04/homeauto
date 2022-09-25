import 'package:flutter/material.dart';
import '/utils/show_progress.dart';
import '/models/manufactured_products.dart';
import 'device_specs.dart';

class ManufacturedDevices extends StatefulWidget {
  const ManufacturedDevices({Key? key}) : super(key: key);

  @override
  State<ManufacturedDevices> createState() => _ManufacturedDevicesState();
}

class _ManufacturedDevicesState extends State<ManufacturedDevices>
    implements ManufacturedProductsContracor {
  bool _isLoading = true;
  List<Products> _list = <Products>[];
  late ManufacturedProductsPresenter _presenter;

  @override
  void initState() {
    _presenter = new ManufacturedProductsPresenter(this);
    _getProductsList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getProductsList() async {
    await _presenter.doGetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          _isLoading ? ShowProgress() : createProductsListView(context, _list),
    );
  }

  Widget _productWidget(BuildContext context, Products product) {
    return Card(
        child: ListTile(
      title: Text(product.deviceName!),
      subtitle: Text(product.deviceType!),
      leading: Container(
          child: Image(
              image: NetworkImage(Uri.parse(product.deviceImage!).toString()))),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: ((context) => ProductSpecs(product: product)),
          ),
        ),
      ),
    ));
  }

  Widget createProductsListView(
      BuildContext context, List<Products> productsList) {
    return new ListView.separated(
      itemCount: productsList.length,
      separatorBuilder: (context, index) => new Divider(),
      itemBuilder: (context, index) =>
          _productWidget(context, productsList[index]),
    );
  }

  @override
  void onProductsError(String error) {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onProductsSuccess(List<Products>? products) {
    setState(() {
      _list = products!;
      _isLoading = false;
    });
  }
}
