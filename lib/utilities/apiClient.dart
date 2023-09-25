// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:collection';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:drortho/constants/apiconstants.dart';
import 'package:drortho/utilities/queryString.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final httpClient = http.Client();

  String _getOAuthURL(String requestMethod, String queryUrl) {
    String consumerKey = "ck_3236d99a6c1caf5643a789845c6b253f80da6963";
    String consumerSecret = "cs_176916991d1a8284b03791dcff72299526004d51";

    String token = "";
    String url = queryUrl;
    bool containsQueryParams = url.contains("?");

    Random rand = Random();
    List<int> codeUnits = List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    /// Random string uniquely generated to identify each signed request
    String nonce = String.fromCharCodes(codeUnits);

    /// The timestamp allows the Service Provider to only keep nonce values for a limited time
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    String parameters =
        "oauth_consumer_key=${consumerKey}&oauth_nonce=${nonce}&oauth_signature_method=HMAC-SHA1&oauth_timestamp=${timestamp.toString()}&oauth_token=${token}&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap =  SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString =
          "$parameterString${Uri.encodeQueryComponent(key)}=${treeMap[key]}&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    String method = requestMethod;
    String baseString =
        "${method}&${Uri.encodeQueryComponent(containsQueryParams == true ? url.split("?")[0] : url)}&${Uri.encodeQueryComponent(parameterString)}";

    String signingKey = consumerSecret + "&" + token;
    crypto.Hmac hmacSha1 =
        crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1

    /// The Signature is used by the server to verify the
    /// authenticity of the request and prevent unauthorized access.
    /// Here we use HMAC-SHA1 method.
    crypto.Digest signature = hmacSha1.convert(utf8.encode(baseString));

    String finalSignature = base64Encode(signature.bytes);

    String requestUrl = "";

    if (containsQueryParams == true) {
      requestUrl =
          "${url.split("?")[0]}?${parameterString}&oauth_signature=${Uri.encodeQueryComponent(finalSignature)}";
    } else {
      requestUrl =
          "${url}?${parameterString}&oauth_signature=${Uri.encodeQueryComponent(finalSignature)}";
    }
    return requestUrl;
  }

  Future<dynamic> callGetAPI(String endpoint) async {
    try {
      final url = _getOAuthURL("GET", baseURL + endpoint);
      http.Response response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "Application/json"
      }); //using JWT token for WP authentication is not needed

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> callPostAPI(String endpoint, Map body) async {
    try {
      final url = _getOAuthURL("POST", baseURL + endpoint);
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "Application/json"},
        body: jsonEncode(body),
      ); //using JWT token for WP authentication is not needed
  
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> callPutAPI(String endpoint, Map body) async {
    try {
      final url = _getOAuthURL("PUT", baseURL + endpoint);
      http.Response response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "Application/json"},
        body: jsonEncode(body),
      ); //using JWT token for WP authentication is not needed
 
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> calDeleteAPI(String endpoint, Map? body) async {
    try {
      final url = _getOAuthURL("DELETE", baseURL + endpoint);
      http.Response response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "Application/json"},
        body: jsonEncode(body),
      ); //using JWT token for WP authentication is not needed
   
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createRazorPayOrder(
      double price, String wcOrderKey, String wcOrderId) async {
    try {
      final body = {
        "amount": price,
        "currency": "INR",
        "receipt": wcOrderKey,
        "notes": {
          "woocommerce_order_id": wcOrderId,
          "woocommerce_order_number": wcOrderId
        }
      };
      String basicAuth =
          'Basic ${base64.encode(utf8.encode('$rzrPayKey:$rzrPaySecret'))}';
      http.Response response = await http.post(
        Uri.parse(razorpayCreateOrderURL),
        headers: {
          "Content-Type": "Application/json",
          'authorization': basicAuth
        },
        body: jsonEncode(body),
      ); //using JWT token for WP authentication is not needed
     
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw jsonDecode(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }
}
