#!/usr/bin/env bash
set -euo pipefail

cd /workspaces/Summit26-InteractiveLab

echo "Downloading JMeter 5.6.3..."
curl -L -o apache-jmeter-5.6.3.tgz \
  https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz

echo "Extracting..."
tar -xzf apache-jmeter-5.6.3.tgz

echo "Downloading Snowflake JDBC driver..."
curl -L -o snowflake-jdbc.jar \
  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.16.1/snowflake-jdbc-3.16.1.jar

echo "Copying JDBC driver..."
cp snowflake-jdbc.jar apache-jmeter-5.6.3/lib/
cp snowflake-jdbc.jar jmeter/

echo ""
echo "Done. Run the following to activate this JMeter install:"
echo ""
echo "  export JMETER_HOME=/workspaces/Summit26-InteractiveLab/apache-jmeter-5.6.3"
echo "  export PATH=\$JMETER_HOME/bin:\$PATH"
echo ""
echo "Then run the concurrency test:"
echo ""
echo "  cd jmeter && ./run_concurrency_test.sh SUMMIT_INT_WH"
