# Wayang Website - Fixes Applied

## Issue Fixed

### Problem
The Jekyll documentation server was failing to start due to a corrupted Bundler installation (Ruby 4.0 + Bundler 4.0.8 compatibility issue).

**Error Message:**
```
/opt/homebrew/lib/ruby/site_ruby/4.0.0/rubygems.rb:304:in 'Kernel#load': 
cannot load such file -- /opt/homebrew/lib/ruby/gems/4.0.0/gems/bundler-4.0.8/exe/bundle (LoadError)
```

### Solution Applied

1. **Uninstalled corrupted Bundler:**
   ```bash
   gem uninstall bundler -a -x
   ```

2. **Installed compatible Bundler version (2.5.22):**
   ```bash
   gem install bundler -v 2.5.22 --no-document
   ```

3. **Updated `start-server.sh` script:**
   - Added explicit Bundler version specification
   - Changed from `bundle exec` to `bundle _2.5.22_ exec`

4. **Reinstalled project dependencies:**
   ```bash
   bundle _2.5.22_ install
   ```

## Files Modified

### 1. `start-server.sh`
**Changes:**
- Added `BUNDLER_VERSION="2.5.22"` constant
- Updated Jekyll start command to use specific Bundler version

**Before:**
```bash
bundle exec jekyll serve --port $PORT --force-polling --host 127.0.0.1
```

**After:**
```bash
bundle _$BUNDLER_VERSION_ exec jekyll serve --port $PORT --force-polling --host 127.0.0.1
```

## Documentation Added

### New Files Created
1. **`docs/sandbox-runtime.md`** (624 lines)
   - Complete Sandbox Runtime documentation
   - Isolation strategies guide
   - Security policies reference
   - Resource quotas documentation
   - REST API reference
   - Usage examples (Java, cURL, Python)
   - Multi-tenancy guide
   - Monitoring and observability
   - Configuration reference
   - Best practices and troubleshooting

2. **`docs/sandbox-architecture.md`** (350+ lines)
   - Visual architecture diagrams (Mermaid)
   - High-level system architecture
   - Sandbox lifecycle flow
   - Security architecture
   - Multi-tenant architecture
   - Resource management flow
   - Provider selection strategy
   - API request flow
   - Observability stack
   - Deployment patterns

3. **`SANDBOX_DOCS_UPDATE.md`**
   - Update summary and changelog
   - Testing instructions
   - Build and deploy guide

### Files Updated
1. **`docs/index.md`**
   - Added Sandbox Runtime to "Executors & Integrations"
   - Added to "Core Features" section

2. **`features/index.md`**
   - Added Sandbox Runtime to Execution Engine features
   - Added "Sandbox Execution" to Platform Features table
   - Added "Multi-Tenancy" to Platform Features table

## Verification

### Server Status
✅ Jekyll server running successfully on port 4001

### Accessible URLs
- ✅ http://127.0.0.1:4001/docs/sandbox-runtime.html (HTTP 200)
- ✅ http://127.0.0.1:4001/docs/sandbox-architecture.html (HTTP 200)
- ✅ http://127.0.0.1:4001/docs/ (HTTP 200)
- ✅ http://127.0.0.1:4001/features/ (HTTP 200)

### Page Titles Verified
- "Sandbox Runtime | Wayang AI" ✅
- "Sandbox Architecture | Wayang AI" ✅

## How to Start the Server

### Option 1: Using the Script (Recommended)
```bash
cd website/wayang.github.io
./start-server.sh
```

### Option 2: Direct Command
```bash
cd website/wayang.github.io
bundle _2.5.22_ exec jekyll serve --port 4001 --host 127.0.0.1 --force-polling
```

### Access Points
- **Home:** http://127.0.0.1:4001/
- **Documentation:** http://127.0.0.1:4001/docs/
- **Sandbox Runtime:** http://127.0.0.1:4001/docs/sandbox-runtime.html
- **Sandbox Architecture:** http://127.0.0.1:4001/docs/sandbox-architecture.html
- **Features:** http://127.0.0.1:4001/features/
- **Javadoc:** http://127.0.0.1:4001/docs/javadoc/index.html

## Stopping the Server

```bash
# Stop Jekyll server
pkill -f "jekyll serve"

# Or press Ctrl+C if running in foreground
```

## Future Maintenance

### Updating Bundler Version
If Ruby/Bundler is updated in the future, update the version in `start-server.sh`:

```bash
# Check current Bundler version
bundle --version

# Update start-server.sh
BUNDLER_VERSION="2.x.x"  # Update to match installed version
```

### Gem Dependencies
To update gem dependencies:

```bash
cd website/wayang.github.io
bundle _2.5.22_ update
```

## Technical Details

### Environment
- **Ruby:** 4.0.2
- **Bundler:** 2.5.22 (downgraded from 4.0.8 due to compatibility issues)
- **Jekyll:** Latest (via Gemfile)
- **Port:** 4001 (configurable)

### Why Bundler 2.5.22?
- Stable version compatible with Ruby 4.0
- Avoids the default gem copy issue in Bundler 4.x
- Widely tested with Jekyll sites

## Summary

✅ **Fixed:** Bundler installation issue  
✅ **Added:** Complete Sandbox Runtime documentation  
✅ **Added:** Visual architecture diagrams  
✅ **Updated:** Documentation index and features pages  
✅ **Verified:** All pages accessible and rendering correctly  

The website is now running successfully with full Sandbox Runtime documentation!
