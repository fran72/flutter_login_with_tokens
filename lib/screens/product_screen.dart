import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_cap14/providers/providers.dart';
import 'package:flutter_app_cap14/services/services.dart';
import 'package:flutter_app_cap14/ui/ui.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
        create: (_) => ProductFormProvider(productsService.selectedProduct),
        child: _ProductScreenBody(productsService: productsService));
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    required this.productsService,
  });

  final ProductsService productsService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('producto'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                ProductImage(url: productsService.selectedProduct.picture),
                Positioned(
                  top: 20,
                  left: 10,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 20),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      // final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                      // final XFile? galleryVideo =
                      //     await picker.pickVideo(source: ImageSource.gallery);
                      // final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
                      // final List<XFile> images = await picker.pickMultiImage();
                      // final XFile? media = await picker.pickMedia();
                      // final List<XFile> medias = await picker.pickMultipleMedia();

                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (pickedFile == null) {
                        debugPrint('no tenemos imagen');
                        return;
                      } else {
                        debugPrint('tenemos imagen');

                        productsService
                            .updateSelectedProductImage(pickedFile.path);
                      }
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
            _ProductForm(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: productsService.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.save_outlined),
        onPressed: () async {
          if (!productForm.isValidForm()) return;

          final String imageSecureUrl = await productsService.uploadImage();

          productForm.product.picture = imageSecureUrl;

          await productsService.saveOrCreateProduct(productForm.product);
          debugPrint(
              'final......productsService.isSaving.....${productsService.isSaving}');
        },
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        width: double.infinity,
        height: 220,
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Valor es obligatorio';
                //   }
                //   return null;
                // },
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Nombre del producto',
                  labelText: 'Nombre:',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: '${product.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  if (int.tryParse(value) == null) {
                    product.price = 0;
                  } else {
                    product.price = int.parse(value);
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Precio del producto',
                  labelText: 'Precio:',
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Available'),
                onChanged: (value) => productForm.updateAvailability(value),
              )
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(25),
        bottomLeft: Radius.circular(25),
      ));
}
