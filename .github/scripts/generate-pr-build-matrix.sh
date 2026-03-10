#!/usr/bin/env bash
set -euo pipefail

function github.log() {
	if [ -z "${QUIET_LOGS:-}" ]; then
		echo "$@"
	fi
}

# This script detects files changed in a pull request compared to the main branch.
# It looks for Dockerfiles among the changed files and generates a build matrix accordingly.
# Example:
# consul/1.22.0/Dockerfile
# vault/1.10.0/Dockerfile

GITHUB_BASE_REF=${GITHUB_BASE_REF:-main}
GITHUB_HEAD_REF=${GITHUB_HEAD_REF:-}
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}

RUNNER_TEMP=${RUNNER_TEMP:-$(pwd)}
BUILD_MATRIX_MANIFEST=$(mktemp -p "${RUNNER_TEMP}")
trap 'rm -f "$BUILD_MATRIX_MANIFEST"' EXIT

if [ -z "$GITHUB_HEAD_REF" ]; then
	github.log "This script should be run in the context of a pull request."
	exit 1
fi

BASE_IMAGE_CHANGES=""

github.log "File changed:"
for file in $(git diff "origin/${GITHUB_BASE_REF}" "HEAD" --name-only); do
	github.log "- ${file}"
	if [[ "${file}" == *"/docker-bake.hcl" ]]; then
		target=$(echo "${file}" | cut -d'/' -f1)
		github.log "- Detected change in docker-bake.hcl for target ${target}. This indicates a change in the base image for that target, which may affect all versions of that target. Adding all versions of ${target} to the build matrix."
		BASE_IMAGE_CHANGES+=" ${target}"
		QUIET_LOGS=1 BUILD_MATRIX_MANIFEST=${BUILD_MATRIX_MANIFEST} "$(dirname "$0")"/generate-build-matrix.sh "${target}"
		continue
	fi
	if [[ "${file}" == *"/.empty" ]] || [[ "${file}" == *"/Dockerfile" ]]; then
		# Extract target and version from the file path
		target=$(echo "${file}" | cut -d'/' -f1)
		version=$(echo "${file}" | cut -d'/' -f2)
		# If the target is already marked for build due to a base image change,
		# we can skip adding specific version changes for that target, as they will be included in the build matrix due to the base image change.
		if [[ "${BASE_IMAGE_CHANGES}" == *"${target}"* ]]; then
			github.log "- Skipping ${version} change for ${target} as it is a base image change and the target is already marked for build due to a base image change."
			continue
		fi
		# If the version is "base", it indicates a change to the base image. In this case,
		# we should trigger builds for all versions of that target, as they may be affected by the base image change.
		if [[ "${version}" == "base" ]]; then
			github.log "- Skipping ${version} change for ${target} as it is a base image and not a specific version."
			BASE_IMAGE_CHANGES+=" ${target}"
			QUIET_LOGS=1 BUILD_MATRIX_MANIFEST=${BUILD_MATRIX_MANIFEST} "$(dirname "$0")"/generate-build-matrix.sh "${target}"
			continue
		fi
		# Add to build matrix
		echo "{\"target\":\"${target}\",\"version\":\"${version}\"}" >> "$BUILD_MATRIX_MANIFEST"
	fi
done

# Build JSON array and write to GITHUB_OUTPUT, quoting to prevent word splitting.
if [ -z "${QUIET_LOGS:-}" ]; then
	github.log "Generating build matrix..."
	cat "$BUILD_MATRIX_MANIFEST" | sort | uniq | jq -s '.'
fi

# Set the output variable for GitHub Actions
matrix_json=$(cat "$BUILD_MATRIX_MANIFEST" | sort | uniq | jq -sc '.')
echo "matrix=${matrix_json}" >> "$GITHUB_OUTPUT"
