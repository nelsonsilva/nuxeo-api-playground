part of nuxeo_api_playground.test;

testAutomation() => group('Automation', () {
  test('Lock document', () {
    go("commands").then(expectAsync((_) {
      expect(true, isTrue);
    }));
  });
});
