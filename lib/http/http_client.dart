import 'package:http/http.dart';

class HttpClient {
  final client = Client();

  Future<Response> get({required String url, Map<String, String>? headers}) {
    return client.get(Uri.parse(url), headers:headers);
  }
   //fun assincrona que retorna future initaly incompleto que dps fica com o result pretendido
 //future response 1º no responsta sects laters has resposta
}
