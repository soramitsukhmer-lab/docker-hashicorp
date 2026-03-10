#!/usr/bin/env bash
set -euo pipefail

function github.log() {
	if [ -z "${QUIET_LOGS:-}" ]; then
		echo "$@"
	fi
}

INPUT_TARGET=${INPUT_TARGET:-}
INPUT_VERSION=${INPUT_VERSION:-}

# This script detects files changed in a pull request compared to the main branch.
# It looks for Dockerfiles among the changed files and generates a build matrix accordingly.
# Example:
# library/{version}/Dockerfile
GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}

RUNNER_TEMP=${RUNNER_TEMP:-$(pwd)}
_BUILD_MATRIX_MANIFEST="${BUILD_MATRIX_MANIFEST:-}"
BUILD_MATRIX_MANIFEST=""
if [[ -z "${_BUILD_MATRIX_MANIFEST}" ]]; then
	BUILD_MATRIX_MANIFEST=$(mktemp -p "${RUNNER_TEMP}")
	trap 'rm -f "$BUILD_MATRIX_MANIFEST"' EXIT
else
	BUILD_MATRIX_MANIFEST=${_BUILD_MATRIX_MANIFEST}
fi

if [[ -n "${INPUT_TARGET}" && -n "${INPUT_VERSION}" ]]; then
	# If both target and version are provided, use them directly to generate the build matrix.
	github.log "Using provided target and version: ${INPUT_TARGET}, ${INPUT_VERSION}"
	echo "{\"target\":\"${INPUT_TARGET}\",\"version\":\"${INPUT_VERSION}\"}" >> "$BUILD_MATRIX_MANIFEST"
else
	# If target and version are not provided,
	# detect changed files and generate the build matrix based on the file paths.
	# If no specific libraries are provided as arguments, it will look for all libraries in the repository.
	LIBRARIES=${LIBRARIES:-${@}}
	if [[ -z "${LIBRARIES}" ]]; then
		# shellcheck disable=SC2231
		LIBRARIES=$(ls **/docker-bake.hcl | cut -d/ -f1)
	fi

	github.log "File changed:"
	# shellcheck disable=SC2231
	for lib in ${LIBRARIES}; do
		for file in ${lib}/**/Dockerfile; do
			github.log "- ${file}"
			if [[ "${file}" == *"/.empty" ]] || [[ "${file}" == *"/Dockerfile" ]]; then
				# Extract target and version from the file path
				target=$(echo "${file}" | cut -d'/' -f1)
				version=$(echo "${file}" | cut -d'/' -f2)
				if [[ "${version}" == "base" ]]; then
					github.log "- Skipping ${version} change for ${target} as it is a base image and not a specific version."
					continue
				fi
				# Add to build matrix
				echo "{\"target\":\"${target}\",\"version\":\"${version}\"}" >> "$BUILD_MATRIX_MANIFEST"
			fi
		done
	done
fi

# Build JSON array and write to GITHUB_OUTPUT, quoting to prevent word splitting.
if [ -z "${QUIET_LOGS:-}" ]; then
	github.log "Generating build matrix..."
	cat "$BUILD_MATRIX_MANIFEST" | sort -r | uniq | jq -s '.'
fi

# Set the output variable for GitHub Actions
matrix_json=$(cat "$BUILD_MATRIX_MANIFEST" | sort | uniq | jq -sc '.')
echo "matrix=${matrix_json}" >> "$GITHUB_OUTPUT"
