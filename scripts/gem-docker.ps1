# Build (and optionally push) generate_image using Docker - no local Ruby required.
# Usage (from repo root generate_image/):
#   scripts\gem-docker.cmd build
#   scripts\gem-docker.cmd push
#
# For push: set GEM_HOST_API_KEY (RubyGems API key from https://rubygems.org/profile/edit)
# Optional: load from .env at repo root (see .env.example). Existing env vars win.
#
# MFA (rubygems_mfa_required on this gem): use interactive push, or set GEM_HOST_OTP_CODE for this session only.

param(
    [Parameter(Position = 0)]
    [ValidateSet("build", "push")]
    [string]$Action = "build"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Import-DotEnvIfUnset {
    param([string]$EnvPath)
    if (-not (Test-Path $EnvPath)) { return }
    Get-Content -LiteralPath $EnvPath -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\s*#' -or $line -eq '') { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 0) { return }
        $key = $line.Substring(0, $eq).Trim()
        if ($key -eq '') { return }
        $val = $line.Substring($eq + 1).Trim()
        if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
            $val = $val.Substring(1, $val.Length - 2)
        }
        $existing = [Environment]::GetEnvironmentVariable($key, "Process")
        if ([string]::IsNullOrEmpty($existing)) {
            Set-Item -Path "env:$key" -Value $val
        }
    }
}

function Get-GemVersion {
    param([string]$RepoRoot)
    $path = Join-Path $RepoRoot "lib\generate_image\version.rb"
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    if ($raw -match 'VERSION\s*=\s*"([0-9.]+)"') {
        return $Matches[1]
    }
    throw "Could not parse VERSION from $path"
}

if ($Action -eq "build") {
    $buildInner = "export DEBIAN_FRONTEND=noninteractive && apt-get update -qq && apt-get install -y --no-install-recommends git >/dev/null && gem build generate_image.gemspec && ls -la *.gem"
    docker run --rm -v "${Root}:/gem" -w /gem ruby:3.2-slim bash -lc $buildInner
    Write-Host ""
    Write-Host "Gem file is in: $Root" -ForegroundColor Green
    exit 0
}

if ($Action -eq "push") {
    Import-DotEnvIfUnset -EnvPath (Join-Path $Root ".env")
    if (-not $env:GEM_HOST_API_KEY) {
        Write-Host "Set GEM_HOST_API_KEY (RubyGems API key) in .env or your shell." -ForegroundColor Red
        Write-Host '  $env:GEM_HOST_API_KEY = "rubygems_..."' -ForegroundColor Yellow
        Write-Host "Create a key at: https://rubygems.org/profile/edit" -ForegroundColor Cyan
        exit 1
    }
    $Version = Get-GemVersion -RepoRoot $Root
    $GemFile = "generate_image-$Version.gem"
    $gemPath = Join-Path $Root $GemFile
    if (-not (Test-Path $gemPath)) {
        Write-Host "Missing $GemFile - run: scripts\gem-docker.cmd build" -ForegroundColor Red
        exit 1
    }
    $inner = "gem push $GemFile"
    if (-not [string]::IsNullOrEmpty($env:GEM_HOST_OTP_CODE)) {
        docker run --rm -e GEM_HOST_API_KEY -e GEM_HOST_OTP_CODE -v "${Root}:/gem" -w /gem ruby:3.2-slim bash -lc $inner
        exit $LASTEXITCODE
    }
    Write-Host "MFA: run this from an interactive terminal so Docker can prompt for the 6-digit code." -ForegroundColor Cyan
    Write-Host "Or set GEM_HOST_OTP_CODE for a one-time non-interactive push (do not save OTP in .env)." -ForegroundColor DarkGray
    docker run --rm -i -t -e GEM_HOST_API_KEY -v "${Root}:/gem" -w /gem ruby:3.2-slim bash -lc $inner
    exit $LASTEXITCODE
}
