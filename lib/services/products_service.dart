import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl =
      'flutter-app-20026-default-rtdb.europe-west1.firebasedatabase.app';
  final List<Product> products = [];
  late Product selectedProduct;

  final storage = const FlutterSecureStorage();

  bool isLoading = false;
  bool isSaving = false;

  File? newPictureFile;

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json',
        {"auth": await storage.read(key: 'token') ?? ''});
    final response = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(response.body);

    productsMap.forEach((key, value) {
      final tempProd = Product.fromJson(value);
      tempProd.id = key;
      products.add(tempProd);
    });

    isLoading = false;
    notifyListeners();

    return products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {"auth": await storage.read(key: 'token') ?? ''});
    final response = await http.put(url, body: product.toRawJson());
    final decodedData = response.body;

    debugPrint('decodedData......$decodedData');

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    // return product.id!;
  }

  Future createProduct(Product product) async {
    debugPrint('create product...........');

    final url = Uri.https(_baseUrl, 'products.json',
        {"auth": await storage.read(key: 'token') ?? ''});
    final response = await http.post(url, body: product.toRawJson());
    final decodedData = json.decode(response.body);

    debugPrint(decodedData['name']);

    product.id = decodedData['name'];

    products.add(product);

    // return product.id;
  }

  void updateSelectedProductImage(String path) {
    selectedProduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String> uploadImage() async {
    if (newPictureFile == null) return '';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dprucnvyy/upload');

    final imageUploadRequest = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'flutter'
      ..files
          .add(await http.MultipartFile.fromPath('file', newPictureFile!.path));

    final streamResponse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) return 'null';
    newPictureFile = null;

    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
