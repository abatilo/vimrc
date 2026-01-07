# Version Detection Reference

When exploring a repository that is a dependency of the current project, check out the specific version being used. This ensures you're looking at the exact code the project depends on.

## Detection Workflow

1. Identify the package name from the repo (often matches repo name, but not always)
2. Search dependency files in the current working directory
3. Extract the pinned/resolved version
4. Map to a git tag and checkout

## Dependency Files by Ecosystem

### Node.js / JavaScript / TypeScript

#### package.json
```json
{
  "dependencies": {
    "lodash": "^4.17.21",
    "express": "~4.18.2"
  },
  "devDependencies": {
    "typescript": "5.0.0"
  }
}
```
- Version may have prefixes: `^`, `~`, `>=`, etc.
- For exact version, check lockfiles

#### package-lock.json
```json
{
  "packages": {
    "node_modules/lodash": {
      "version": "4.17.21",
      "resolved": "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz"
    }
  }
}
```
- `version` field has the exact resolved version

#### yarn.lock
```
lodash@^4.17.21:
  version "4.17.21"
  resolved "https://registry.yarnpkg.com/lodash/-/lodash-4.17.21.tgz"
```
- Version on second line after `version "`

#### pnpm-lock.yaml
```yaml
packages:
  /lodash@4.17.21:
    resolution: {integrity: sha512-...}
```
- Version in the package path after `@`

---

### Go

#### go.mod
```
require (
    github.com/gin-gonic/gin v1.9.1
    golang.org/x/text v0.14.0
)
```
- Version after package path
- May include `// indirect` suffix (ignore it)
- Pseudo-versions like `v0.0.0-20231215164722-abcdef123456` indicate a specific commit

#### go.sum
```
github.com/gin-gonic/gin v1.9.1 h1:4+...
github.com/gin-gonic/gin v1.9.1/go.mod h1:...
```
- Confirms exact version from go.mod

**Go version to tag mapping:**
- `v1.9.1` → tag `v1.9.1`
- `v0.0.0-20231215164722-abcdef123456` → commit `abcdef123456`

---

### Python

#### requirements.txt
```
requests==2.31.0
flask>=2.0.0,<3.0.0
django~=4.2.0
```
- `==` pins exact version
- For ranges, may need to check installed version or use lower bound

#### pyproject.toml (Poetry)
```toml
[tool.poetry.dependencies]
python = "^3.9"
requests = "^2.31.0"
django = {version = "^4.2", optional = true}
```

#### poetry.lock
```toml
[[package]]
name = "requests"
version = "2.31.0"
```
- `version` field has exact resolved version

#### Pipfile
```toml
[packages]
requests = "==2.31.0"
flask = "*"
```

#### Pipfile.lock
```json
{
  "default": {
    "requests": {
      "version": "==2.31.0"
    }
  }
}
```

#### setup.py / setup.cfg
```python
install_requires=[
    'requests>=2.20.0',
    'click>=7.0',
]
```

**Python version to tag mapping:**
- `2.31.0` → try `v2.31.0`, then `2.31.0`
- Some projects use `release-2.31.0`

---

### Rust

#### Cargo.toml
```toml
[dependencies]
serde = "1.0"
tokio = { version = "1.35", features = ["full"] }
```

#### Cargo.lock
```toml
[[package]]
name = "serde"
version = "1.0.193"
source = "registry+https://github.com/rust-lang/crates.io-index"
```
- `version` field has exact resolved version

**Rust version to tag mapping:**
- `1.0.193` → try `v1.0.193`, then `1.0.193`

---

### Ruby

#### Gemfile
```ruby
gem 'rails', '~> 7.0.0'
gem 'puma', '>= 5.0'
```

#### Gemfile.lock
```
GEM
  specs:
    rails (7.0.8)
    puma (6.4.0)
```
- Version in parentheses after gem name

**Ruby version to tag mapping:**
- `7.0.8` → try `v7.0.8`, then `7.0.8`

---

### Java / Kotlin

#### pom.xml (Maven)
```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <version>6.1.2</version>
</dependency>
```
- Check `<version>` element
- May use properties: `${spring.version}`

#### build.gradle / build.gradle.kts (Gradle)
```groovy
dependencies {
    implementation 'org.springframework:spring-core:6.1.2'
    implementation("com.google.guava:guava:33.0.0-jre")
}
```
- Version after second colon

**Java version to tag mapping:**
- `6.1.2` → try `v6.1.2`, then `6.1.2`
- Spring uses tags like `v6.1.2`

---

### .NET / C#

#### *.csproj
```xml
<ItemGroup>
    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
</ItemGroup>
```

#### Directory.Packages.props (Central Package Management)
```xml
<ItemGroup>
    <PackageVersion Include="Newtonsoft.Json" Version="13.0.3" />
</ItemGroup>
```

#### packages.config (legacy)
```xml
<packages>
    <package id="Newtonsoft.Json" version="13.0.3" />
</packages>
```

---

### PHP

#### composer.json
```json
{
    "require": {
        "laravel/framework": "^10.0"
    }
}
```

#### composer.lock
```json
{
    "packages": [
        {
            "name": "laravel/framework",
            "version": "v10.40.0"
        }
    ]
}
```

---

### Elixir

#### mix.exs
```elixir
defp deps do
  [
    {:phoenix, "~> 1.7.0"},
    {:ecto, "~> 3.11"}
  ]
end
```

#### mix.lock
```elixir
%{
  "phoenix": {:hex, :phoenix, "1.7.10", ...},
}
```

---

## Tag Lookup Strategy

After extracting version `X.Y.Z`, try these git tags in order:

```bash
cd ~/.cache/claude/repos/<owner>/<repo>
git fetch --all --tags

# Try in order:
git checkout v<X.Y.Z>      # Most common: v1.2.3
git checkout <X.Y.Z>        # Without prefix: 1.2.3
git checkout release-<X.Y.Z>
git checkout release/<X.Y.Z>
git checkout <package>-<X.Y.Z>  # Monorepo style
```

List available tags to find the pattern:
```bash
git tag -l | head -20
git tag -l "*<version>*"
```

## Handling Version Ranges

If only a range is specified (e.g., `^1.2.0`, `>=2.0`):
1. Prefer lockfile versions (always exact)
2. If no lockfile, checkout latest matching tag
3. Inform user which version was selected

## Monorepo Considerations

Some repos contain multiple packages. Tags may be prefixed:
- `@scope/package@1.2.3`
- `package-v1.2.3`
- `packages/foo/v1.2.3`

Check the repo's releases page pattern if standard tags don't match.
