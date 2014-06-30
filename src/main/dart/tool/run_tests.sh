#!/bin/bash

# Display installed versions.
dart --version

which content_shell
if [[ $? -ne 0 ]]; then
    $DART_SDK/../chromium/download_contentshell.sh
    unzip content_shell-linux-x64-release.zip

    cs_path=$(ls -d drt-*)
    PATH=$cs_path:$PATH
fi

pub serve&
PUBPID=$!
echo "Pub serve started ($PUBPID)"

# Wait for pub serve
sleep 10

echo "Running tests..."

results=$(content_shell --args --allow-external-pages --dump-render-tree http://localhost:8081/test.html)

# Extract JUnit report and write to file
junit=$(echo $results | grep -oP "<testsuite(.*)</testsuite>")
mkdir -p ../../../target/surefire-reports
echo $junit > ../../../target/surefire-reports/test-results.xml

# Check passed
if [ "$DRONE" = "true" ]; then
	echo -e "$results" | grep 'unittest-suite-success' >/dev/null
fi

# Kill pub serve
kill $PUBPID

#node_modules/jasmine-node/bin/jasmine-node &&
#  node "node_modules/karma/bin/karma" start karma.conf \
#    --reporters=junit,dots --port=8765 --runner-port=8766 \
#    -single-run --no-colors #--browsers=Dartium,Chrome,Firefox -
