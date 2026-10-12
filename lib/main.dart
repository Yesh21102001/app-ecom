import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'config/shopify_config.dart';
import 'data/shopify_storefront_repository.dart';
import 'screens/main_shell.dart';
import 'state/shop_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (ShopifyConfig.isConfigured) {
    unawaited(
      shop.loadCatalog(
        ShopifyStorefrontRepository(
          storeDomain: ShopifyConfig.storeDomain,
          storefrontToken: ShopifyConfig.storefrontToken,
          apiVersion: ShopifyConfig.storefrontApiVersion,
        ),
      ),
    );
  } else {
    shop.reportNotConnected();
  }
  runApp(const App(home: MainShell()));
}
