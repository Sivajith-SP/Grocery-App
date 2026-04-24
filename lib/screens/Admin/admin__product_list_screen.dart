import 'package:flutter/material.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/screens/Admin/edit_product.dart';
import 'package:grocery_app/services/product_services.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  List<Product> products = [];
  bool isLoading = false;

  final ProductServices _productService = ProductServices();

  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();
    productsFuture=_productService.getAllProducts();
    loadProducts();
  }

  //delete products
  void deleteProduct(String id) async{

    await _productService.deleteProduct(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(microseconds: 900),
        backgroundColor: Colors.red,
        content: Text(
          "Product Deleted",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    loadProducts();

  }

  //load products
  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });

    products = await _productService.getProducts();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Products"),
        centerTitle: true,
      ),

      body: FutureBuilder(future: _productService.getAllProducts(), builder: (context,snapshot){
        return  isLoading
            ? Center(child: CircularProgressIndicator())
            : products.isEmpty
            ? Center(child: Text("No Products found"))
            : ListView.builder(
          padding: .symmetric(horizontal: 10),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                elevation: 0,
                margin: .all(10),
                child: Padding(
                  padding: .all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          //img
                          ClipRRect(
                            borderRadius: .circular(10),
                            child: Image.network(product.image, height: 70,
                              width: 70,
                              fit: .cover,),
                          ),

                          SizedBox(width: 12,),

                          //details

                          Expanded(
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    product.title, style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: .bold,
                                  ),),
                                  Text("\₹ ${product.price} "),
                                ],
                              )
                          ),

                          //edit
                          IconButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductScreen(product: product),));
                            },
                            icon: Icon(Icons.edit,color: Colors.green,),
                          ),
                          //delete
                          IconButton(
                            onPressed: () => deleteProduct(product.id!),
                            icon: Icon(Icons.delete_outline,color: Colors.red,),
                          ),

                        ],
                      )
                    ],
                  ),
                ),
              );
            }
        );
      })
    );
  }
}
