const String baseURL = "https://app.drorthooil.com";
const String razorpayCreateOrderURL = "https://api.razorpay.com/v1/orders";
const String rzrPayKey = "rzp_test_3sqaYOQBaTRwqC";
const String rzrPaySecret = "i38QTmuw4Fss2CvTJPmnzxPv";
const String productsEndpoint = "/wp-json/wc/v3/products?status=publish";
const String categoriesEndpoint = "/wp-json/wc/v3/products/categories";
const String bannersEndpoint = "/wp-json/wp/v2/banners";
const String gridProductsEndpoint =
    "/wp-json/wc/v3/products?status=publish&category=60";
const String categoryItemsEndpoint =
    "/wp-json/wc/v3/products?status=publish&category=";
const String productDetailsEndpoint = "/wp-json/wc/v3/products/";
const String homeEndpoint = "/wp-json/wp/v2/home";
const String blogEndpoint = "/wp-json/wp/v2/posts?_embed&status=publish";
const String featuredProductsEndpoint =
    "/wp-json/wc/v3/products?status=publish&featured=true";
const String registerEndpoint = "/wp-json/wp/v2/users/register";
const String loginEndpoint = "/wp-json/jwt-auth/v1/token";
const String createOrderEndpoint = "/wp-json/wc/v3/orders";
const String getUserOrdersEndpoint = "/wp-json/wc/v3/orders?customer=";
const String getUserDataEndpoint = "/wp-json/wc/v3/customers/";
const String deleteAccountEndpoint = "/wp-json/wc/v3/customers/";
const String updateAccountEndpoint = "/wp-json/wc/v3/customers/";
const String searchEndpoint = "/wp-json/wc/v3/products?status=publish&search=";
const String getProductFromSlug = "/wp-json/wc/v3/products?slug=";
const String getCoupon = "/wp-json/wc/v3/coupons?code=";
const String productReview = "/wp-json/wc/v3/products/reviews";
const String productSize = "/wp-json/wc/v3/products?slug=";
const String productVariationEndPoint = "/wp-json/wc/v3/products/";
const String codEndpoint = "/wp-json/wc/v3/payment_gateways";
const String sendResetPasswordEmail = "/wp-json/bdpwr/v1/reset-password";
const String validateCodeResetPassword = "/wp-json/bdpwr/v1/validate-code";
const String setNewPassword = "/wp-json/bdpwr/v1/set-password";
