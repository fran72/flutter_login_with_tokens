import 'package:flutter/material.dart';
import 'package:flutter_app_cap14/models/models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Container(
          margin: const EdgeInsets.only(bottom: 20), //left: 10, right: 10,
          width: double.infinity,
          height: 350,
          decoration: _boxDecoration(),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              _BackgroundImage(picture: product.picture),
              _ProductDetails(name: product.name, id: product.id),
              Positioned(
                top: 0,
                right: 0,
                child: _PriceProduct(price: product.price),
              ),
              if (!product.available)
                Positioned(
                  top: 0,
                  left: 0,
                  child: _NotAvailable(available: product.available),
                ),
            ],
          )),
    );
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 7),
            blurRadius: 10,
          ),
        ]);
  }
}

class _NotAvailable extends StatelessWidget {
  final bool available;
  const _NotAvailable({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 120,
      height: 70,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(25),
        ),
      ),
      child: const FittedBox(
        fit: BoxFit.contain,
        child: Text(
          'Not available',
          style: TextStyle(color: Colors.white, fontSize: 21),
        ),
      ),
    );
  }
}

class _PriceProduct extends StatelessWidget {
  final int price;
  const _PriceProduct({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 120,
      height: 70,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          '\$ $price',
          style: const TextStyle(color: Colors.white, fontSize: 21),
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final String name;
  final String? id;
  const _ProductDetails({required this.name, required this.id});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        height: 60,
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              id!,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() => const BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ));
}

class _BackgroundImage extends StatelessWidget {
  final String? picture;
  const _BackgroundImage({required this.picture});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: SizedBox(
        width: double.infinity,
        height: 400,
        child: picture == null
            ? const Image(
                image: AssetImage('assets/no-image.png'),
                fit: BoxFit.cover,
              )
            : Container(
                padding: const EdgeInsets.all(40),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/jar-loading.gif'),
                  image: NetworkImage(picture!),
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
