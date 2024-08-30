#!/bin/bash

BASE_DIR=$(pwd)
IS_MAC_M1_BUILD=false  # Set to true for Mac M1 builds
export GRADLE_OPTS="-Dorg.gradle.daemon=true -Xmx512m -XX:MaxMetaspaceSize=256m"

# Adjust to Logstash 8 JARs in build.gradle
adjustToLogstash8() {
  local sed_cmd
  if [ "$IS_MAC_M1_BUILD" = false ]; then
    sed_cmd='s/logstash-core-.*\.jar/logstash-core.jar/'
    sed "$sed_cmd" build.gradle > tmp && mv tmp build.gradle
  else
    sed_cmd='s/logstash-core-*.*.*.jar/logstash-core.jar/'
    sed -i "$sed_cmd" build.gradle
  fi
}

# Builds a gem from the specified plugin directory.
buildUCPluginGem() {
  local plugin_dir="$1"

  echo "================ Building $plugin_dir gem file ================="
  cd "${BASE_DIR}/${plugin_dir}" || { echo "Failed to enter directory ${BASE_DIR}/${plugin_dir}"; exit 1; }

  adjustToLogstash8

  cp "${BASE_DIR}/build/gradle.properties" .

  # Adjust Gradle options for low resource environments
  ./gradlew --no-daemon test </dev/null >/dev/null 2>&1
  TEST_STATUS=$?

  ./gradlew --no-daemon gem </dev/null >/dev/null 2>&1
  GEM_STATUS=$?

  if [ $TEST_STATUS -eq 0 ] && [ $GEM_STATUS -eq 0 ]; then
    echo "Successfully tested and built gem $plugin_dir"
  else
    echo "Failed to test or build gem $plugin_dir"
    exit 1
  fi
}


# Control the number of parallel jobs to avoid resource exhaustion
run_limited_parallel_jobs() {
  local max_jobs=$1
  shift
  local jobs=()

  for job in "$@"; do
    $job &
    jobs+=($!)
    if [ "${#jobs[@]}" -ge "$max_jobs" ]; then
      wait -n
      jobs=("${jobs[@]/$!}")
    fi
  done

  wait "${jobs[@]}"
}

# Build the UC Commons project
buildUCCommons() {
  echo "================ Building UC Commons ================="
  cd "${BASE_DIR}/common" || { echo "Failed to enter directory ${BASE_DIR}/common"; exit 1; }

  if ./gradlew test </dev/null >/dev/null 2>&1; then
    echo "Successfully tested uc-commons"
  else
    echo "Failed to test uc-commons"
    exit 1
  fi

  if ./gradlew jar </dev/null >/dev/null 2>&1; then
    echo "Successfully built jar uc-commons"
  else
    echo "Failed to build jar uc-commons"
    exit 2
  fi

  cp ./build/libs/common-1.0.0.jar ./build/libs/guardium-universalconnector-commons-1.0.0.jar
  cd "${BASE_DIR}" || exit
}

# Build Java plugins specified in the javaPluginsToBuild.txt file
buildJavaPlugins() {
  echo "================ Building Java Plugins ================="
  local plugins=()
  while IFS= read -r plugin; do
    [[ -z "$plugin" || "$plugin" =~ ^# ]] && continue  # Skip comments or empty lines
    plugins+=("buildUCPluginGem $plugin")
  done < "${BASE_DIR}/build/javaPluginsToBuild.txt"

  run_limited_parallel_jobs 4 "${plugins[@]}"  # Adjust the max_jobs value as needed
}

# Build Ruby plugins specified in the rubyPluginsToBuild.txt file
buildRubyPlugins() {
  echo "================ Building Ruby Plugins ================="
  local plugins=()
  while IFS= read -r plugin; do
    [[ -z "$plugin" || "$plugin" =~ ^# ]] && continue  # Skip comments or empty lines
    plugins+=("buildRubyPlugin \"$plugin\" \"${plugin##*/}.gemspec\"")
  done < "${BASE_DIR}/build/rubyPluginsToBuild.txt"

  run_limited_parallel_jobs 4 "${plugins[@]}"  # Adjust the max_jobs value as needed
}

# Build a Ruby plugin from the specified directory and gemspec
buildRubyPlugin() {
  local plugin_dir="$1"
  local gemspec="$2"
  echo "================ Building Ruby Plugin in $plugin_dir ================="
  cd "${BASE_DIR}/${plugin_dir}" || { echo "Failed to enter directory ${BASE_DIR}/${plugin_dir}"; exit 1; }

  bundle install >/dev/null 2>&1
  if gem build "$gemspec"; then
    echo "Successfully built Ruby plugin with gemspec $gemspec"
  else
    echo "Failed to build Ruby plugin with gemspec $gemspec"
    exit 1
  fi
}

# Main script execution
echo "================ Starting Build Process ================="

buildUCCommons

# Run Java and Ruby plugin builds in parallel with limited jobs
buildJavaPlugins &
buildRubyPlugins &
wait  # Wait for all parallel builds to complete

echo "================ Build Process Complete ================="

exit 0
