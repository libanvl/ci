# Libanvl GitHub Workflows and Actions

Workflows and actions for GitHub

## Actions

### actions/download-assets

Downloads the assets attached to a release.

### actions/push-to-nuget

Push NuGet packages to a feed using the dotnet CLI.

## Resuable Workflows

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
