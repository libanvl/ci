param (
  [string]$pattern = "*",
  [string]$release = $null,
  [string]$token,
  [string]$outputPath = "assets",
  [int]$releaseId = $null
)

# Function to fetch release by ID
function Get-ReleaseById {
  param (
    [string]$repository,
    [string]$token,
    [int]$releaseId
  )
  $url = "https://api.github.com/repos/$repository/releases/$releaseId"
  $headers = @{ Authorization = "token $token" }
  
  Write-Verbose "Fetching release from URL: $url"

  try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -TimeoutSec 30
    
    Write-Host "Successfully fetched release."
    return $response
  }
  catch {
    Write-Error "Failed to fetch release: $_"
    exit 1
  }
}

# Set the output path rooted at the runner working directory
$rootedOutputPath = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath $outputPath

# Create the output directory
if (-Not (Test-Path -Path $rootedOutputPath)) {
  Write-Verbose "Creating output directory: $rootedOutputPath"
  New-Item -ItemType Directory -Path $rootedOutputPath
} else {
  Write-Verbose "Output directory already exists: $rootedOutputPath"
}

# Parse the release context or fetch release by ID
if ($null -eq $release) {
  if ($null -eq $releaseId) {
      Write-Error "Release context or release ID must be provided."
      exit 1
  }
  $repository = $env:GITHUB_REPOSITORY
  $releaseData = Get-ReleaseById -repository $repository -token $token -releaseId $releaseId
} else {
  try {
      $releaseData = $release | ConvertFrom-Json
  }
  catch {
      Write-Error "Invalid JSON format for release: $_"
      exit 1
  }
}

# Extract asset URLs and download assets
$assets = $releaseData.assets | Where-Object { $_.name -like $pattern }

if ($assets.Count -eq 0) {
  Write-Error "No assets found for pattern: $pattern"
  exit 1
}

foreach ($asset in $assets) {
  $assetUrl = $asset.browser_download_url
  $assetName = $asset.name
  try {
    Invoke-WebRequest -Uri $assetUrl -OutFile (Join-Path -Path $rootedOutputPath -ChildPath $assetName) -Headers @{ Authorization = "token $token" }
    Write-Host "Downloaded asset: $assetName to $rootedOutputPath"
  }
  catch {
    Write-Error "Failed to download asset: $assetName from $assetUrl. Error: $_"
  }
}
