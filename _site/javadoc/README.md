# Wayang AI Platform Javadoc

This directory contains the generated Javadoc API documentation for the Wayang AI Platform.

## How to Generate

### Quick Start

From the project root directory:

```bash
# Using the convenience script
cd website/wayang.github.io/javadoc
./generate-javadoc.sh
```

### Manual Generation

```bash
# From the wayang-platform root directory
cd wayang
mvn javadoc:aggregate-no-fork -DskipTests -Dmaven.test.skip=true -Dcompiler.skipMainCompilation=true
```

The generated documentation will be placed in this directory.

## Viewing the Documentation

Once generated, you can view the Javadoc by:

1. **Locally**: Open `index.html` in your browser
   ```bash
   open index.html
   ```

2. **Via Jekyll**: If you're running the Jekyll site locally, navigate to `/docs/javadoc/index.html`
   ```bash
   cd website/wayang.github.io
   bundle exec jekyll serve
   # Then visit: http://localhost:4000/docs/javadoc/index.html
   ```

3. **Online**: Once deployed to GitHub Pages, the documentation will be available at `https://wayang-ai.github.io/docs/javadoc/index.html`

## Structure

The Javadoc is organized by module and includes:

### Core APIs
- **Project API** (`tech.kayys.wayang.project.api`) - Project and workflow descriptors
- **Control API** (`tech.kayys.wayang.control.api`) - REST API resources
- **Schema API** (`tech.kayys.wayang.schema`) - Schema registry and catalog

### Control Plane
- **Control Core** (`tech.kayys.wayang.control`) - Designer services, agent management
- **Control SPI** (`tech.kayys.wayang.control.spi`) - Control plane interfaces
- **Debugger** (`tech.kayys.wayang.debugger`) - Execution debugging support

### Executors
- **Agent Executor** (`tech.kayys.wayang.executor.agent`) - Agent execution engine
- **EIP** (`tech.kayys.wayang.eip`) - Enterprise integration patterns
- **Embedding** (`tech.kayys.wayang.embedding`) - Embedding providers
- **Guardrails** (`tech.kayys.wayang.guardrail`) - Input/output guardrails
- **HITL** (`tech.kayys.wayang.hitl`) - Human-in-the-loop execution
- **Memory** (`tech.kayys.wayang.memory`) - Memory and context management
- **RAG** (`tech.kayys.wayang.rag`) - Retrieval-augmented generation
- **Tool** (`tech.kayys.wayang.tool`) - Tool execution and MCP
- **Vector** (`tech.kayys.wayang.vector`) - Vector store providers

### Infrastructure
- **Plugin System** (`tech.kayys.wayang.plugin`) - Plugin SPI and registry
- **Vault Manager** (`tech.kayys.wayang.vault`) - Secure credential management
- **Orchestrator** (`tech.kayys.wayang.orchestrator`) - Workflow orchestration

## Configuration

The Javadoc generation is configured in `wayang/pom.xml` with the following settings:

- **Output directory**: `website/wayang.github.io/javadoc`
- **Java source version**: 25
- **Encoding**: UTF-8
- **Includes**: Author, Version, Use information
- **Links to**: Oracle Java 25 API docs
- **Doclint**: Disabled for faster generation

## Troubleshooting

### Build Errors

#### Compilation Errors

If you encounter compilation errors during Javadoc generation:

```bash
# First, install dependencies without tests
cd wayang-platform
mvn clean install -DskipTests

# Then generate Javadoc
cd wayang
mvn javadoc:aggregate-no-fork -DskipTests
```

**Common Issue:** Missing symbols or cannot find symbol errors
- **Cause:** Dependencies not installed in local Maven repository
- **Solution:** Run `mvn clean install -DskipTests` first

**Common Issue:** Package does not exist
- **Cause:** Module dependencies not built
- **Solution:** Build the entire project: `mvn clean install -DskipTests -pl wayang`

#### Module Build Failures

If specific modules fail during Javadoc generation:

```bash
# Skip problematic modules and generate for others
cd wayang
mvn javadoc:aggregate-no-fork -DskipTests -Dmaven.javadoc.skip=true -pl !module-to-skip
```

### Memory Issues

#### OutOfMemoryError

If you encounter `java.lang.OutOfMemoryError: Java heap space`:

```bash
# Increase Maven heap size
export MAVEN_OPTS="-Xmx4g -XX:MaxMetaspaceSize=1g"
mvn javadoc:aggregate-no-fork -DskipTests
```

**Recommended settings for large projects:**
- Minimum: `-Xmx2g`
- Recommended: `-Xmx4g`
- For very large projects: `-Xmx8g`

### Javadoc Generation Issues

#### Empty Javadoc Output

If the javadoc directory is empty after generation:

1. Check if Javadoc plugin is configured correctly:
   ```bash
   cd wayang
   mvn help:effective-pom | grep -A 20 maven-javadoc-plugin
   ```

2. Verify output directory configuration:
   ```bash
   grep -A 5 "reportOutputDirectory" wayang/pom.xml
   ```

3. Manually copy from module directories:
   ```bash
   # Find generated Javadoc
   find wayang -name "index.html" -path "*/javadoc/*"
   
   # Copy to website directory
   cp -r wayang/website/wayang.github.io/javadoc/* website/wayang.github.io/javadoc/
   ```

#### Missing Classes in Javadoc

If some classes are missing from the generated Javadoc:

1. **Check source files:** Ensure classes have proper JavaDoc comments
   ```java
   /**
    * This class provides...
    */
   public class MyClass { }
   ```

2. **Check package-info.java:** Ensure packages are documented
   ```java
   /**
    * Package description here.
    */
   package tech.kayys.wayang.mypackage;
   ```

3. **Verify module inclusion:** Check that all modules are in the reactor build
   ```bash
   mvn help:evaluate -Dexpression=project.modules -q -DforceStdout
   ```

#### Encoding Errors

If you see encoding-related warnings or errors:

```bash
# Set proper encoding
export MAVEN_OPTS="-Dfile.encoding=UTF-8"
mvn javadoc:aggregate-no-fork -DskipTests -Dencoding=UTF-8 -Ddocencoding=UTF-8
```

**Check system locale:**
```bash
locale  # Should show UTF-8
```

### Jekyll Integration Issues

#### Javadoc Not Accessible via Jekyll

If Javadoc pages return 404 when running Jekyll:

1. **Check _config.yml:** Ensure javadoc is in the include list
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

4. **Verify Jekyll ignore config:** Check `.jekyll-ignore` doesn't exclude javadoc

#### CSS/JS Not Loading

If Javadoc styles or search don't work:

1. **Check resource files:**
   ```bash
   ls -la website/wayang.github.io/javadoc/resource-files/
   ls -la website/wayang.github.io/javadoc/script-files/
   ```

2. **Regenerate Javadoc:** Resource files may be missing
   ```bash
   ./generate-javadoc.sh
   ```

3. **Check base URL:** If deploying to subdirectory, update links

### Performance Issues

#### Slow Javadoc Generation

If Javadoc generation takes too long:

1. **Use parallel builds:**
   ```bash
   mvn javadoc:aggregate-no-fork -T 1C -DskipTests
   ```

2. **Skip doclint (faster but less validation):**
   Already configured in pom.xml with `-Xdoclint:none`

3. **Generate for specific modules only:**
   ```bash
   mvn javadoc:javadoc -pl wayang-core -DskipTests
   ```

#### Large Javadoc Size

If the generated Javadoc is too large (>500MB):

1. **Exclude test sources:** Already configured with `-Dmaven.test.skip=true`

2. **Reduce detail level:**
   ```xml
   <additionalJOptions>
     <additionalJOption>-Xdoclint:none</additionalJOption>
     <additionalJOption>-quiet</additionalJOption>
   </additionalJOptions>
   ```

3. **Split by module:** Generate separate Javadoc per module

### Platform-Specific Issues

#### macOS

**Issue:** Too many open files
```bash
# Increase file descriptor limit
ulimit -n 4096
mvn javadoc:aggregate-no-fork
```

**Issue:** Command too long
```bash
# Use response file
mvn javadoc:aggregate-no-fork -Dmaven.javadoc.useResponseFile=true
```

#### Linux

**Issue:** Missing fonts for Javadoc generation
```bash
# Install fonts (Debian/Ubuntu)
sudo apt-get install fonts-dejavu-core

# Install fonts (RHEL/CentOS)
sudo yum install dejavu-sans-fonts
```

#### Windows

**Issue:** Path length limitations
```powershell
# Enable long paths in Windows 10+
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
```

**Issue:** PowerShell execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### CI/CD Integration

#### GitHub Actions

Example workflow for Javadoc generation:

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

#### GitLab CI

```yaml
javadoc:
  stage: docs
  image: maven:3.9-eclipse-temurin-25
  script:
    - cd wayang
    - mvn javadoc:aggregate-no-fork -DskipTests
    - cp -r website/wayang.github.io/javadoc/* ../website/wayang.github.io/javadoc/
  artifacts:
    paths:
      - website/wayang.github.io/javadoc/
    expire_in: 1 week
```

### Diagnostic Commands

Useful commands for troubleshooting:

```bash
# Check Maven version
mvn -version

# Check Java version
java -version

# View effective POM
mvn help:effective-pom -f wayang/pom.xml

# List all Javadoc goals
mvn javadoc:help

# Debug Javadoc generation
mvn javadoc:aggregate-no-fork -X 2>&1 | tee javadoc-debug.log

# Check generated files count
find website/wayang.github.io/javadoc -type f | wc -l

# Check Javadoc size
du -sh website/wayang.github.io/javadoc/

# Validate HTML (requires tidy)
tidy -e website/wayang.github.io/javadoc/index.html
```

### Getting Help

If issues persist:

1. **Check Maven logs:**
   ```bash
   tail -100 /tmp/javadoc-generation.log
   ```

2. **Enable debug mode:**
   ```bash
   mvn javadoc:aggregate-no-fork -X > debug.log 2>&1
   ```

3. **Check known issues:**
   - [Maven Javadoc Plugin Issues](https://issues.apache.org/jira/projects/MJAVADOC)
   - [OpenJDK Javadoc Bugs](https://bugs.openjdk.org/)

4. **Community support:**
   - Stack Overflow: Tag with `maven` and `javadoc`
   - Maven Users mailing list: users@maven.apache.org

## Related Documentation

- [Projects API Guide](../docs/projects-api.md)
- [Schema Catalog](../docs/schema-catalog.md)
- [Agent Skills](../docs/agent-skills.md)
- [RAG API](../docs/rag.md)
- [MCP Integration](../docs/mcp.md)
- [Guardrails](../docs/guardrails.md)
- [HITL](../docs/hitl.md)
