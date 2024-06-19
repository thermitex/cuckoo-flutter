import 'package:cuckoo/src/common/extensions/extensions.dart';
import 'package:cuckoo/src/common/services/constants.dart';
import 'package:cuckoo/src/common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SettingsTipPage extends StatefulWidget {
  const SettingsTipPage({super.key});

  @override
  State<SettingsTipPage> createState() => _SettingsTipPageState();
}

class _SettingsTipPageState extends State<SettingsTipPage> {
  /// Products fetched from underlying stores
  List<ProductDetails>? _products;

  void _fetchProducts() async {
    final ProductDetailsResponse response = await InAppPurchase.instance
        .queryProductDetails(Constants.kIAPProductIDs);
    response.productDetails.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    setState(() => _products = response.productDetails);
  }

  void _purchaseProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CuckooAppBar(
        title: '',
        exitButtonStyle: ExitButtonStyle.close,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 33.0),
                    const Icon(
                      Symbols.savings_rounded,
                      color: CuckooColors.primary,
                      weight: 500,
                      size: 80,
                    ),
                    const SizedBox(height: 18.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Text(
                        Constants.kTipJarTitle,
                        style: CuckooTextStyles.body(
                            size: 20, weight: FontWeight.bold, height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      Constants.kTipJarSubtitle,
                      style: CuckooTextStyles.body(
                          height: 1.3, color: context.theme.secondaryText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 33.0),
                    if (_products == null)
                      const SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              color: CuckooColors.primary,
                              strokeWidth: 6.0,
                            ),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const hGap = 16.0;
                          const vGap = 14.0;
                          final blockWidth =
                              (constraints.maxWidth - hGap) / 2.0;

                          Widget tipBlock(ProductDetails product) {
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => _purchaseProduct(product),
                              child: Container(
                                height: 100,
                                width: blockWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: context.theme.secondaryBackground,
                                ),
                                child: Center(
                                  child: Text(
                                    product.price,
                                    style: CuckooTextStyles.body(
                                        size: 18.0, weight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Wrap(
                            spacing: hGap,
                            runSpacing: vGap,
                            children: List.generate(_products!.length,
                                (index) => tipBlock(_products![index])),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
