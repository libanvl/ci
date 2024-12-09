param (
  [string]$pattern = "*",
  [string]$token = $null,
  [string]$outputPath = "assets",
  [string]$releaseId = $null
)

# Function to fetch release by ID
function Get-ReleaseById {
  param (
    [string]$repository,
    [string]$token,
    [string]$releaseId
  )
  $url = "https://api.github.com/repos/$repository/releases/$releaseId"
  $headers = @{ Authorization = "token $token" }
  
  Write-Host "Fetching release from URL: $url"

  try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -TimeoutSec 30
    Write-Host $response
    
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

# Fetch release by ID
if ($releaseId -eq $null) {
  Write-Error "Release ID is required."
  exit 1
}

$repository = $env:GITHUB_REPOSITORY
$release = Get-ReleaseById -repository $repository -token $token -releaseId $releaseId

try {
    $releaseData = $release | ConvertFrom-Json
}
catch {
    Write-Error "Invalid JSON format for release: $_"
    exit 1
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
