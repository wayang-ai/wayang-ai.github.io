---
layout: default
title: Javadoc Troubleshooting Guide
---

# Javadoc Troubleshooting Guide

This guide helps you resolve common issues when generating or viewing the Wayang AI Platform Javadoc documentation.

## Quick Fixes

### Most Common Issues

**Issue: Javadoc generation fails with compilation errors**

```bash
# Solution: Install dependencies first
cd wayang-platform
mvn clean install -DskipTests

# Then regenerate
cd wayang
mvn javadoc:aggregate-no-fork -DskipTests
```

**Issue: OutOfMemoryError during generation**

```bash
# Solution: Increase memory
export MAVEN_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g"
mvn javadoc:aggregate-no-fork -DskipTests
```

**Issue: Javadoc pages return 404 in Jekyll**

```bash
# Solution: Clear cache and rebuild
cd website/wayang.github.io
rm -rf .jekyll-cache _site
bundle exec jekyll clean
bundle exec jekyll serve
```

---

## Table of Contents

1. [Build Errors](#build-errors)
2. [Memory Issues](#memory-issues)
3. [Generation Issues](#generation-issues)
4. [Jekyll Integration](#jekyll-integration)
5. [Performance Issues](#performance-issues)
6. [Platform-Specific Issues](#platform-specific-issues)
7. [CI/CD Integration](#cicd-integration)
8. [Diagnostic Commands](#diagnostic-commands)

---

## Build Errors

### Compilation Errors

**Symptoms:**
- `cannot find symbol` errors
- `package does not exist` errors
- Build fails with exit code 1

**Root Causes:**
1. Dependencies not installed in local Maven repository
2. Module dependencies not built
3. Incorrect module order in reactor build

**Solutions:**

```bash
# Step 1: Clean install all dependencies
cd wayang-platform
mvn clean install -DskipTests

# Step 2: Verify installation
mvn dependency:resolve -f wayang/pom.xml

# Step 3: Generate Javadoc
cd wayang
mvn javadoc:aggregate-no-fork -DskipTests
```

**Prevention:** Always run `mvn clean install -DskipTests` before generating Javadoc.

### Module Build Failures

**Symptoms:**
- Specific module fails during Javadoc generation
- Error message mentions a particular module name

**Solution:** Skip problematic modules temporarily

```bash
# Skip a specific module
mvn javadoc:aggregate-no-fork -DskipTests -pl '!wayang-problematic-module'

# Or build only specific modules
mvn javadoc:aggregate-no-fork -DskipTests -pl wayang-core,wayang-api
```

---

## Memory Issues

### OutOfMemoryError: Java Heap Space

**Symptoms:**
```
java.lang.OutOfMemoryError: Java heap space
    at java.base/java.util.Arrays.copyOf(Arrays.java:3512)
```

**Solution:** Increase Maven heap size

```bash
# Minimum (2GB)
export MAVEN_OPTS="-Xmx2g"

# Recommended (4GB)
export MAVEN_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g"

# For very large projects (8GB)
export MAVEN_OPTS="-Xmx8g -XX:MaxMetaspaceSize=2g"

# Then run
mvn javadoc:aggregate-no-fork -DskipTests
```

**Permanent Solution:** Add to `~/.mavenrc` or `MAVEN_OPTS` environment variable

### Metaspace Errors

**Symptoms:**
```
java.lang.OutOfMemoryError: Metaspace
```

**Solution:**
```bash
export MAVEN_OPTS="-XX:MaxMetaspaceSize=2g"
mvn javadoc:aggregate-no-fork -DskipTests
```

---

## Generation Issues

### Empty Javadoc Output

**Symptoms:** Javadoc directory exists but contains no HTML files

**Diagnostic Steps:**

```bash
# 1. Check plugin configuration
cd wayang
mvn help:effective-pom | grep -A 20 maven-javadoc-plugin

# 2. Verify output directory
grep "reportOutputDirectory" pom.xml

# 3. Check for generation errors
ls -la target/site/
```

**Solutions:**

1. **Manual copy from module directories:**
   ```bash
   find wayang -name "index.html" -path "*/javadoc/*"
   cp -r wayang/website/wayang.github.io/javadoc/* website/wayang.github.io/javadoc/
   ```

2. **Regenerate with verbose output:**
   ```bash
   mvn javadoc:aggregate-no-fork -X 2>&1 | tee javadoc-debug.log
   ```

### Missing Classes in Javadoc

**Symptoms:** Some classes or packages don't appear in generated Javadoc

**Checklist:**

1. **Verify JavaDoc comments exist:**
   ```java
   /**
    * This class provides...
    */
   public class MyClass { }
   ```

2. **Check package-info.java:**
   ```java
   /**
    * Package description.
    */
   package tech.kayys.wayang.mypackage;
   ```

3. **Verify module inclusion:**
   ```bash
   mvn help:evaluate -Dexpression=project.modules -q -DforceStdout
   ```

### Encoding Errors

**Symptoms:**
- Warning messages about encoding
- Special characters display incorrectly

**Solution:**
```bash
export MAVEN_OPTS="-Dfile.encoding=UTF-8"
mvn javadoc:aggregate-no-fork -DskipTests -Dencoding=UTF-8 -Ddocencoding=UTF-8
```

**Verify locale:**
```bash
locale  # Should show UTF-8
```

---

## Jekyll Integration

### Javadoc Returns 404

**Symptoms:** Navigating to `/docs/javadoc/index.html` shows 404 error

**Solutions:**

1. **Check _config.yml:**
   ```yaml
   include:
     - javadoc
   ```

2. **Clear Jekyll cache:**
   ```bash
   cd website/wayang.github.io
   rm -rf .jekyll-cache _site
   bundle exec jekyll clean
   bundle exec jekyll serve
   ```

3. **Check file permissions:**
   ```bash
   chmod -R 755 website/wayang.github.io/javadoc
   ```

4. **Verify .jekyll-ignore:**
   ```bash
   cat .jekyll-ignore  # Should NOT contain 'javadoc'
   ```

### CSS/JS Not Loading

**Symptoms:** Javadoc pages load but have no styling or search doesn't work

**Solutions:**

1. **Check resource files exist:**
   ```bash
   ls -la website/wayang.github.io/javadoc/resource-files/
   ls -la website/wayang.github.io/javadoc/script-files/
   ```

2. **Regenerate if missing:**
   ```bash
   ./generate-javadoc.sh
   ```

3. **Check browser console:** Look for 404 errors on CSS/JS files

---

## Performance Issues

### Slow Javadoc Generation

**Symptoms:** Generation takes >10 minutes

**Solutions:**

1. **Use parallel builds:**
   ```bash
   mvn javadoc:aggregate-no-fork -T 1C -DskipTests
   ```

2. **Generate only for changed modules:**
   ```bash
   mvn javadoc:javadoc -pl wayang-core -DskipTests
   ```

3. **Use incremental builds:**
   ```bash
   mvn javadoc:aggregate-no-fork -DskipTests -Dmaven.javadoc.useIncremental=true
   ```

### Large Javadoc Size

**Symptoms:** Generated Javadoc >500MB

**Solutions:**

1. **Exclude test sources** (already configured)

2. **Reduce detail level in pom.xml:**
   ```xml
   <additionalJOptions>
     <additionalJOption>-Xdoclint:none</additionalJOption>
     <additionalJOption>-quiet</additionalJOption>
   </additionalJOptions>
   ```

3. **Split by module:**
   Generate separate Javadoc per module instead of aggregated

---

## Platform-Specific Issues

### macOS

**Issue: Too many open files**

```bash
# Check current limit
ulimit -n

# Increase limit
ulimit -n 4096

# Then run
mvn javadoc:aggregate-no-fork
```

**Issue: Command line too long**

```bash
# Use response file
mvn javadoc:aggregate-no-fork -Dmaven.javadoc.useResponseFile=true
```

### Linux

**Issue: Missing fonts**

```bash
# Debian/Ubuntu
sudo apt-get install fonts-dejavu-core

# RHEL/CentOS
sudo yum install dejavu-sans-fonts

# Then regenerate
mvn javadoc:aggregate-no-fork
```

### Windows

**Issue: Path length limitations**

```powershell
# Enable long paths (Windows 10+)
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# Restart terminal and retry
```

**Issue: PowerShell execution policy**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## CI/CD Integration

### GitHub Actions

**Issue: Javadoc generation fails in CI**

**Solution:** Use this workflow template:

```yaml
name: Generate Javadoc

on:
  push:
    branches: [ main ]

jobs:
  javadoc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 25
        uses: actions/setup-java@v4
        with:
          java-version: '25'
          distribution: 'temurin'
          cache: maven
      
      - name: Install dependencies
        run: mvn clean install -DskipTests -f wayang/pom.xml
      
      - name: Generate Javadoc
        run: |
          cd wayang
          mvn javadoc:aggregate-no-fork -DskipTests -Dmaven.test.skip=true
          cp -r website/wayang.github.io/javadoc/* ../website/wayang.github.io/javadoc/
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./website/wayang.github.io
```

### GitLab CI

**Issue: Artifacts too large**

**Solution:** Compress Javadoc

```yaml
javadoc:
  stage: docs
  image: maven:3.9-eclipse-temurin-25
  script:
    - cd wayang
    - mvn javadoc:aggregate-no-fork -DskipTests
    - cp -r website/wayang.github.io/javadoc/* ../website/wayang.github.io/javadoc/
    - tar -czf javadoc.tar.gz -C website/wayang.github.io javadoc
  artifacts:
    paths:
      - javadoc.tar.gz
    expire_in: 1 week
```

---

## Diagnostic Commands

Useful commands for troubleshooting:

```bash
# Check versions
mvn -version
java -version

# View effective POM configuration
mvn help:effective-pom -f wayang/pom.xml

# List Javadoc goals
mvn javadoc:help

# Debug generation (verbose)
mvn javadoc:aggregate-no-fork -X 2>&1 | tee javadoc-debug.log

# Check generated files
find website/wayang.github.io/javadoc -type f | wc -l

# Check size
du -sh website/wayang.github.io/javadoc/

# Validate HTML
tidy -e website/wayang.github.io/javadoc/index.html

# Check for broken links
find website/wayang.github.io/javadoc -name "*.html" -exec grep -l "href=\"#\"" {} \;
```

---

## Getting Help

If issues persist after trying these solutions:

### 1. Check Logs

```bash
# Recent Maven logs
tail -100 /tmp/javadoc-generation.log

# Debug log
cat javadoc-debug.log | grep -i error
```

### 2. Enable Debug Mode

```bash
mvn javadoc:aggregate-no-fork -X > debug.log 2>&1
# Search for "ERROR" or "FAILURE" in debug.log
```

### 3. Known Issues

- [Maven Javadoc Plugin JIRA](https://issues.apache.org/jira/projects/MJAVADOC)
- [OpenJDK Javadoc Bugs](https://bugs.openjdk.org/)

### 4. Community Support

- **Stack Overflow:** Tag with `maven` and `javadoc`
- **Maven Users List:** users@maven.apache.org
- **Wayang GitHub Issues:** Create an issue with debug logs

---

## Related Documentation

- [Javadoc README](./javadoc/README)
- [Projects API Guide](./projects-api)
- [Schema Catalog](./schema-catalog)
- [Agent Skills](./agent-skills)
