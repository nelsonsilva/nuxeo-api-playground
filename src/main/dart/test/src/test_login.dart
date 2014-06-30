part of nuxeo_api_playground.test;

testLogin() => group('Connection', () {
  test('Login', () {
    var conn = document.querySelector('#connection');
    expect(conn, isNotNull);

    var btn = conn.shadowRoot.querySelector(".button").click();

    observePath(conn, 'isConnected').then(expectAsync((connected) {
      expect(connected, isTrue);
    }));

  });
});