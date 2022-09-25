import 'package:flutter/material.dart';
import '/screens/add_device/connect_to_device.dart';
import '/constants/colors.dart';
import '/models/manufactured_products.dart';

class ProductSpecs extends StatefulWidget {
  final Products product;

  const ProductSpecs({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductSpecs> createState() => _ProductSpecsState();
}

class _ProductSpecsState extends State<ProductSpecs> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.deviceName!),
        centerTitle: true,
      ),
      body: Container(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 15),
            child: Container(
              width: size.width,
              height: size.height * 0.5,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(28.0)),
                  gradient: LinearGradient(
                      colors: [kHAutoLightGrey, kHAutoDarkGrey],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(221, 17, 17, 17),
                      blurRadius: 10,
                      offset: Offset(8, 8),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Image.network(widget.product.deviceImage!),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Container(
              child: SingleChildScrollView(
                child: Column(children: [
                  Text(
                    widget.product.deviceName!,
                    style: const TextStyle(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.product.deviceSpecs!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 17,
                        letterSpacing: 2.0,
                        wordSpacing: 7.0),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    widget.product.deviceDesc!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 17,
                        letterSpacing: 2.0,
                        wordSpacing: 7.0),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) =>
                                  ConnectToDevice(product: widget.product)),
                            ),
                          ),
                      child: Text("Add this Device")),
                ]),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
