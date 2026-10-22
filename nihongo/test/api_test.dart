import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nihongo/core/api.dart';

void main() {
  test('GET sends a bearer token to authenticated endpoints', () async {
    http.Request? capturedRequest;
    final client = ApiClient(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'results': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.dispose);

    await client.get(
      ApiConfig.dictionarySearch,
      queryParameters: {'q': '日', 'lang': 'vi', 'limit': '20'},
      bearerToken: 'session-token',
    );

    expect(capturedRequest?.url.path, '/dictionary/search');
    expect(capturedRequest?.url.queryParameters['q'], '日');
    expect(capturedRequest?.headers['authorization'], 'Bearer session-token');
  });

  test('POST sends a bearer token to authenticated endpoints', () async {
    http.Request? capturedRequest;
    final client = ApiClient(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('{}', 200);
      }),
    );
    addTearDown(client.dispose);

    await client.post(ApiConfig.login, const {
      'email': 'a@example.com',
    }, bearerToken: 'session-token');

    expect(capturedRequest?.headers['authorization'], 'Bearer session-token');
  });
}
