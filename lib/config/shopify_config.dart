/// Shopify connection settings.
///
/// The defaults point at the Groves Box store and its Storefront API token.
/// The Storefront token is public by design: it is meant for client apps and
/// only reads catalog data. Never put an Admin API token in the app.
///
/// To use another store, override at run time:
///
///   flutter run --dart-define-from-file=config/shopify.local.json
class ShopifyConfig {
  const ShopifyConfig._();

  static const storeDomain = String.fromEnvironment(
    'SHOPIFY_STORE_DOMAIN',
    defaultValue: 'groves-box-6krgzmin.myshopify.com',
  );

  static const storefrontToken = String.fromEnvironment(
    'SHOPIFY_STOREFRONT_TOKEN',
    defaultValue: '9736ee6c805b175fa1075bb5c55a7793',
  );

  static const storefrontApiVersion = '2026-04';

  static bool get isConfigured =>
      storeDomain.isNotEmpty && storefrontToken.isNotEmpty;
}
