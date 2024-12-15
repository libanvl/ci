# Libanvl GitHub Workflows and Actions

Workflows and actions for GitHub

## Actions

### actions/download-assets

Downloads the assets attached to a release.

### actions/push-to-nuget

Push NuGet packages to a feed using the dotnet CLI.

## Resuable Workflows

### workflows/dotnet-ci-os.yml

This GitHub Actions workflow is designed for Continuous Integration (CI) of .NET projects.
It includes steps for building, testing, packaging, and releasing .NET applications.
The workflow supports multiple configurations and .NET versions, and can optionally collect code coverage, pack NuGet packages, push packages to GitHub Package Feed, and create draft releases.

#### Workflow Inputs

- os: Operating system to run on (default: 'ubuntu-latest')
- configuration: Configuration to build (default: 'Release')
- dotnet-version: .NET version to use or 'global' to use global.json (default: '8.x.x')
- dotnet-verbosity: Verbosity for dotnet (default: 'normal')
- coverage: Collect code coverage (default: true)
- pack: Pack NuGet package (default: true)
- push-github: Push to GitHub package feed (default: true)
- draft-release: Prepare draft release (default: true)

#### Workflow Secrets

- CODECOV_TOKEN: Token for Codecov (optional)

#### Jobs

- build: Runs the build process, including restoring dependencies, building the project, running tests, collecting code coverage, and packing NuGet packages.
- push-github: Pushes the NuGet package to the GitHub package feed if enabled.
- draft-release: Creates a draft release on GitHub if enabled.

#### The build job includes the following steps

- Checkout the repository
- Setup .NET environment
- Use Nerdbank.GitVersioning to manage versioning
- Restore dependencies
- Build the project
- Run tests with or without code coverage
- Pack the project into a NuGet package
- Upload the package as an artifact
- Upload code coverage results to Codecov

#### The push-github job includes the following steps

- Download the package artifact
- Push the package to the GitHub package feed

#### The draft-release job includes the following steps

- Download the package artifact
- Create a draft release on GitHub with the package files

### workflows/release-to-nuget.yml

#### Publish Example

```yaml
name: Publish to GitHub Package Feed

on:
  release:
    types: [published]

jobs:
  call-release-to-nuget:
    uses: libanvl/github/workflows/release-to-nuget.yml@main
    with:
      release-id: ${{ github.event.release.id }}
      push-github-feed: true # optional - defaults to true
      push-nuget-feed: false # optional - defaults to false
```

#### Dispatch Example

```yaml
name: Manual Release

on:
  workflow_dispatch:
    inputs:
      release-id:
        description: 'The ID of the release'
        required: true
        type: string
      push-feed:
        description: 'Where to push the release'
        required: true
        type: choice
        options:
          - github
          - nuget
          - both

jobs:
  call-manual-release:
    uses: libanvl/github/workflows/release-to-nuget.yml@main
    with:
      release-id: ${{ github.event.inputs.release-id }}
      push-github-feed: ${{ contains(['github', 'both'], github.event.inputs.push-feed) }}
      push-nuget-feed: ${{ contains(['nuget', 'both'], github.event.inputs.push-feed) }}
```
