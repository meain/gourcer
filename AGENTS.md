This file provides guidance when working with code in this repository.

## Project Overview

This is **Gourcer** - an automated system that generates Gource visualizations for trending GitHub repositories and uploads them to YouTube. The project is designed to run as a batch processing system that:

1. Scrapes GitHub trending repositories daily
2. Clones repositories and analyzes their git history
3. Generates Gource video visualizations
4. Uploads the videos to YouTube automatically

## Architecture

The system consists of several shell scripts that work together:

- **scripts/add-trending**: Scrapes GitHub trending page, filters repositories by star count (>50), and adds them to the pending queue
- **scripts/get-pending-repo**: Selects the next repository from the pending queue for processing
- **scripts/generate-description**: Extracts repository metadata (author, description, stats, commit history)
- **gourcer**: Main orchestration script that runs inside Docker container to generate the Gource visualization
- **create-video**: Generates the actual Gource video using ffmpeg and uploads to YouTube
- **scripts/commit-pending-list**: Commits and pushes changes to the pending queue back to the repository
- **scripts/check-links**: Validates repository URLs and removes dead links from the pending queue

## Key Files

- `pending`: Large queue file (~441KB) containing repositories to process (format: `- https://github.com/user/repo` for pending, `x https://github.com/user/repo` for processed)
- `repo`: Contains the currently selected repository URL
- `tests/`: Contains test data and expected output for validation
- `Dockerfile`: Ubuntu 14.04 container with gource, ffmpeg, and YouTube uploader tools

## Development Commands

### Testing
```bash
./scripts/test
```
Runs the test suite which clones a test repository, generates stats, and compares output against expected results.

### Processing Pipeline
```bash
./scripts/add-trending                       # Fetch trending repos and update pending queue
./scripts/get-pending-repo                   # Select next repo for processing
./scripts/generate-description > description # Generate repository statistics
./gourcer                           # Generate Gource video (runs in Docker)
./scripts/commit-pending-list [tag]         # Commit and push changes to pending queue
```

### Utility Commands
```bash
./scripts/check-links             # Validate repository URLs and remove dead links
```

### Docker Usage
The main processing happens in a Docker container:
```bash
docker run -v /path/to/repo:/repo -v /path/to/results:/results gourcer
```

## Data Flow

1. `scripts/add-trending` script fetches GitHub trending repositories and adds high-starred ones to `pending`
2. `scripts/get-pending-repo` picks the next repository and writes URL to `repo` file
3. `scripts/generate-description` clones the repository and extracts metadata for video description
4. `gourcer` orchestrates the video generation process inside Docker
5. `create-video` generates the Gource visualization and uploads to YouTube
6. `scripts/commit-pending-list` commits the updated pending queue back to git

## External Dependencies

- **Gource**: Git repository visualization tool
- **FFmpeg**: Video encoding
- **youtubeuploader**: CLI tool for YouTube API uploads
- **pup**: HTML parsing for scraping GitHub
- **jq**: JSON processing for GitHub API responses
- **xvfb**: Virtual display for headless video generation

## GitHub Workflows

The project leverages GitHub Actions to automate the entire video generation and upload process. There are three main workflows:

### 1. Add Trending Repositories (`add-trending.yml`)
- **Trigger**: Daily at 1:10 AM UTC via cron schedule, plus manual dispatch
- **Purpose**: Fetches trending repositories and updates the pending queue
- **Steps**:
  1. Runs `./scripts/add-trending` to scrape GitHub trending and update pending queue
  2. Commits changes with `[trending]` tag via `./scripts/commit-pending-list`

### 2. Create and Upload Video (`create-video.yml`)
- **Trigger**: Every 6 hours (at :13 minutes) via cron schedule, plus manual dispatch
- **Purpose**: Processes repositories from the existing pending queue
- **Steps**:
  1. Selects next repository with `./scripts/get-pending-repo`
  2. Marks completion with `./scripts/commit-pending-list`
  3. Clones repository and generates metadata with `./scripts/generate-description`
  4. Creates and uploads video using Docker container `meain/gourcer:latest`

### 3. Testing (`test.yml`)
- **Trigger**: Pushes to master + daily at 1:10 AM UTC
- **Purpose**: Validates the system functionality
- **Steps**: Runs `./scripts/test` script to verify components work correctly

### Workflow Secrets
All video generation workflows require these GitHub Secrets:
- `CLIENT_SECRETS`: YouTube API client credentials JSON
- `REQUEST_TOKEN`: YouTube API OAuth token for uploads

### Key Workflow Features
- **Automated Queue Management**: Workflows automatically update the pending queue and commit changes
- **Docker-based Processing**: All video generation happens in isolated containers
- **Redundant Scheduling**: Multiple workflows ensure continuous operation
- **Manual Triggers**: All workflows support `workflow_dispatch` for manual execution
- **YouTube Integration**: Direct upload to YouTube channel via API

## Configuration

The system expects these environment variables when running:
- `CLIENT_SECRETS`: YouTube API client secrets JSON
- `REQUEST_TOKEN`: YouTube API request token
- `TITLE`: Video title
- `DESCRIPTION`: Video description
- `RES`: Video resolution (default: 1920x1080)

## Notes

- The system maintains its own git repository state and automatically commits progress
- Processing time is dynamically adjusted based on repository size (max 10 minutes for large repos)
- The pending queue serves as both a work queue and processing history
- Repository validation removes dead links to keep the queue clean
- **GitHub Actions is the primary execution platform** - the system runs entirely on GitHub's infrastructure
