
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/).

## 2021-05-25

### Changed

- Updated Borgmatic from v1.6.0 to v1.6.1. Read the [change notes](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.6.1)
- Updated Dockerfile to chmod script on COPY rather than via a separate chmod step. 
- Updated dependencies. 

## 2021-04-26

### Changed

- Updated Borgmatic from v1.5.24 to v1.6.0. Read the [change notes](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.6.0)

## 2021-04-05

### Changed

- Updated alpine to 3.15.4
 
## 2021-03-29

### Changed

- Updated alpine to 3.15.3

## 2021-03-14

### Changed

- Updated to latest dependencies.
- Updated Changelog

## [1.5.24-1.2.0] - 2021-11-22

### Changed

- Updated Borg backup from v1.1.17 to v1.2.0.
- Updated tags to better follow both versions of Borg and Borgmatic

## [1.5.23] - 2021-02-10

### Changed

- Updated Borgmatic to 1.5.23

## [1.5.22] - 2021-01-05
  
### Changed
 
- Updated to latest dependencies.

## [1.5.20] - 2021-10-11
  
### Changed
 
- Updated to latest dependencies.

## [Liveinstall] - 2021-10-11
  
### Changed

- Updated Dockerfile based on the latest version.

## [DockerCLI] - 2021-10-11
  
### Changed

- Updated Dockerfile based on the latest version.

## [1.5.19] - 2021-10-11
  
### Changed
 
- Updated to latest dependencies


## [Liveinstall] - 2021-09-10
  
### Added

- Created Dockerfile based on the latest version.
- `Docker-cli` is installed on startup by default with `LIVEINSTALL` env variable available if you wish to customise.
- Added [wtfc](https://github.com/typekpb/wtfc) script to make sure there is an internet connection prior to running live install.

## [DockerCLI](https://hub.docker.com/layers/164828805/modem7/borgmatic-docker/dockercli/images/sha256-992eeb053c59ad5cc953a4e96c3d702d32bb903b419463a27df9002e8a7f58fd?context=repo) - 2021-09-10
  
### Added

- Created Dockerfile based on the latest version.
- Baked in `docker-cli` during the install

## [1.5.18](https://hub.docker.com/layers/164830365/modem7/borgmatic-docker/1.5.18/images/sha256-12ad2daab8a13192908d9b5f37d7a5c0df1e76c87598bbf330f27c0fc11f78c4?context=repo) - 2021-09-10
  
### Added
 
- Updated readme
- Updated [guide](https://www.modem7.com/books/docker-backup/page/backup-docker-using-borgmatic)
- Updated to latest dependencies
- Added additional builds for docker-cli both as liveinstall and baked in

### Changed
  
- Pinned dependency versions
  - `pip` to `21.2.4`
  - `borgbackup` to `1.1.17`
  - `borgmatic` to `1.5.18`
  - `llfuse` to `1.4.1`

- Added `LIVEINSTALL` env variable to [liveinstall](https://hub.docker.com/layers/164828783/modem7/borgmatic-docker/liveinstall/images/sha256-9d53d2f4f00b7cf1e468db4a1ec10ac3698e0e61a7c0e666d6ac7954fc7f3aa2?context=repo) tag to allow for custom installation options
  - If `LIVEINSTALL` is not declared in your compose file then `docker-cli` gets installed by default. 

- Added Changelog.
 
## [1.5.14](https://hub.docker.com/layers/164832068/modem7/borgmatic-docker/1.5.14/images/sha256-f80eaa0fd3a9e1b42d91fb4fb677d07a43bdcfbc87db43f5a614b2de47b50209?context=repo) - 2021-09-10
 
### Added
- Cloned [B3vis/Borgmatic](https://hub.docker.com/r/b3vis/borgmatic) repo
  
### Changed

- Updated readme
- Created [guide](https://www.modem7.com/books/docker-backup/page/backup-docker-using-borgmatic)
- Added dependabot
- Added requirements.txt
- Created drone multiarch pipeline
- Added hadolint file
- List what package versions are installed in STDOUT

### Fixed

- Pinned dependency versions
  - `pip` to `20.2.4`
  - `borgbackup` to `1.1.16`
  - `borgmatic` to `1.5.14`
  - `llfuse` to `1.3.8`
