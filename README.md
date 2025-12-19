# Postman CLI GitHub Action

GitHub Action to run [Postman CLI](https://learning.postman.com/docs/postman-cli/postman-cli-overview/) commands in your CI/CD workflows with full support for collection runs, monitors, syntax checks, governance validation, and more.

- [Usage](#usage)
- [Examples](#examples)
- [Customize](#customize)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [Resources](#resources)

## Usage

The following shows how to configure the GitHub Action with a command and your Postman API key. Learn about the [supported inputs](#customize) you can use to customize the GitHub Action.

```yaml
name: API Tests

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run Postman Collection
        uses: postmanlabs/postman-cli-action@v1
        with:
          command: 'collection run 12345678-1234-5678-1234-123456789abc'
          api-key: ${{ secrets.POSTMAN_API_KEY }}
```

The following shows how to set your API key using an environment variable:

```yaml
      - name: Run Postman Collection
        uses: postmanlabs/postman-cli-action@v1
        env:
          POSTMAN_API_KEY: ${{ secrets.POSTMAN_API_KEY }}
        with:
          command: 'collection run 12345678-1234-5678-1234-123456789abc'
```

> **Tip:** You can also run local collection files (for example, `collection run ./tests/collection.json`) without an API key.

## Examples

You can use the following examples to help you configure the Postman CLI GitHub Action:

- [Collection run with an environment](#collection-run-with-an-environment)
- [Collection run with multiple environments](#collection-run-with-multiple-environments)
- [Collection run with reporters](#collection-run-with-reporters)
- [Collection run with iterations](#collection-run-with-iterations)
- [Monitor run](#monitor-run)
- [Specification validation](#specification-validation)
- [API validation](#api-validation)
- [Pin CLI version](#pin-cli-version)
- [Use exit code output](#use-exit-code-output)
- [Complete workflow](#complete-workflow)

### Collection run with an environment

The following example shows how to run a collection using variables defined in an environment:

```yaml
# Local file
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/collection.json --environment tests/environment.json'

# Cloud resources
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run 12345678-collection-id --environment 87654321-environment-id'
    api-key: ${{ secrets.POSTMAN_API_KEY }}
```

### Collection run with multiple environments

The following example shows how to run the same collection using multiple environments:

```yaml
- name: Test Staging
  uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/api.json --environment envs/staging.json'

- name: Test Production
  uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/api.json --environment envs/production.json'
```

### Collection run with reporters

You can generate reports for a collection run. Reports include the requests sent, response codes and times, and the number of passed and failed tests. The Postman CLI supports CLI, JSON, JUnit, and HTML reporters. Learn more about [generating run reports](https://learning.postman.com/docs/postman-cli/postman-cli-reporters/) with the Postman CLI.

```yaml
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/collection.json --reporters cli,json,junit --reporter-json-export results.json --reporter-junit-export results.xml'
```

### Collection run with iterations

The following example shows how to specify the number of times a collection runs and the path to a local data file to use for each iteration. Local data files are supported in JSON or CSV format.

```yaml
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/collection.json --iteration-count 5 --iteration-data tests/data.csv'
```

### Monitor run

The following example shows how to run a monitor:

```yaml
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'monitor run 11111111-2222-3333-4444-555555555555'
    api-key: ${{ secrets.POSTMAN_API_KEY }}
```

### Specification validation

The following example shows how to run syntax validation and governance rule checks against API specifications in [Spec Hub](https://learning.postman.com/docs/design-apis/specifications/overview/):

```yaml
# Local file
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'spec lint specs/openapi.yaml --fail-severity ERROR'

# Cloud spec
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'spec lint 12345678-spec-id --output json --fail-severity ERROR'
    api-key: ${{ secrets.POSTMAN_API_KEY }}
```

### API validation

The following example shows how to run governance and security rule checks against API definitions in the [Postman API Builder](https://learning.postman.com/docs/design-apis/api-builder/overview/):

```yaml
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'api lint 12345678-api-id --fail-severity WARN'
    api-key: ${{ secrets.POSTMAN_API_KEY }}
```

### Pin CLI version

The following example shows how to pin a specific version of the Postman CLI for consistent builds:

```yaml
- uses: postmanlabs/postman-cli-action@v1
  with:
    command: 'collection run tests/collection.json'
    postman-cli-version: '1.27.0'
```

### Use exit code output

The following example shows how to use the exit code output in subsequent steps:

```yaml
- name: Run API Tests
  id: postman
  uses: postmanlabs/postman-cli-action@v1
  continue-on-error: true
  with:
    command: 'collection run tests/collection.json'

- name: Check Test Results
  run: |
    if [ "${{ steps.postman.outputs.exit-code }}" != "0" ]; then
      echo "Tests failed with exit code ${{ steps.postman.outputs.exit-code }}"
      # Add custom failure handling here
    fi
```

### Complete workflow

The following example shows a complete CI/CD workflow using the GitHub Action. Learn about the [supported inputs](#customize) you can use to customize the GitHub Action.

```yaml
name: API Testing

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  api-tests:
    name: Run API Tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Collection Tests
        uses: postmanlabs/postman-cli-action@v1
        with:
          command: 'collection run tests/api-tests.json --environment tests/dev.json --reporters cli,junit --reporter-junit-export results.xml'
          api-key: ${{ secrets.POSTMAN_API_KEY }}
          postman-cli-version: '1.27.0'

      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: results.xml

  monitor:
    name: Run Monitor
    runs-on: ubuntu-latest
    needs: api-tests
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Production Monitor
        uses: postmanlabs/postman-cli-action@v1
        with:
          command: 'monitor run 12345678-monitor-id'
          api-key: ${{ secrets.POSTMAN_API_KEY }}
```

## Customize

Customize the Postman CLI GitHub Action to suit your API project's CI/CD workflow.

### Inputs

| Name | Type | Description |
|------|------|-------------|
| `command` | String | **Required.** The Postman CLI command to run and its options. (For example, `collection run <file>` or `collection run <id>`) |
| `api-key` | String | Your Postman API key for authentication. Required for cloud resources. Optional for local files. |
| `region` | String | Postman API region. Use `eu` for European data residency. Defaults to US region if not specified. |
| `postman-cli-version` | String | Version of Postman CLI to install (for example, `1.27.0`). (Default: `latest`) |
| `working-directory` | String | The directory to run the command from. (Default: `.`) |

### Outputs

| Name | Type | Description |
|------|------|-------------|
| `exit-code` | String | Exit code from the Postman CLI command. `0` indicates success, non-zero indicates failure. |

For all available commands and options, see the [Postman CLI documentation](https://learning.postman.com/docs/postman-cli/postman-cli-options/).

## Resources

- [Postman CLI documentation](https://learning.postman.com/docs/postman-cli/postman-cli-overview/)
- [Postman CLI command options](https://learning.postman.com/docs/postman-cli/postman-cli-options/)
- [Postman API keys](https://go.postman.co/settings/me/api-keys)
- [GitHub Actions documentation](https://docs.github.com/en/actions)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
