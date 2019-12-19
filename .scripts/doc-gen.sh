#!/bin/bash

set -e

NAME="Terraform Enterprise: Clustering"
BINARY_DIR=./work
BINARY_FILE="${BINARY_DIR}/terraform-ci-docgen"
BINARY_VERSION=0.0.2
BINARY_URL_PREFIX="https://github.com/erindatkinson/terraform-ci-docgen/releases/download/v${BINARY_VERSION}/terraform-ci-docgen_${BINARY_VERSION}"

DOCS_CMDS="--sortRequiredFirst --moduleName"

DOCS_DIR=docs
DOC_MD=module.md


function setup {
    mkdir -p ${BINARY_DIR}
    if [[ ! -e "${BINARY_FILE}" ]]; then
        if [[ "$OSTYPE" == "linux-gnu" ]]; then
            BINARY_URL="${BINARY_URL_PREFIX}_linux_amd64.zip"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            BINARY_URL="${BINARY_URL_PREFIX}_darwin_amd64.zip"
        else
            echo "Please run this in either a Linux or Mac environment."     
            exit 1  
        fi
        echo "Downloading ${BINARY_URL}"
        curl -L -o "${BINARY_FILE}.zip" "${BINARY_URL}"
        unzip "${BINARY_FILE}.zip" -d "${BINARY_DIR}"
        chmod +x "${BINARY_FILE}"
    fi
}

function main_docs {
    echo "Writing main docs"
    if test ! -d "${DOCS_DIR}"; then
        mkdir "${DOCS_DIR}"
    fi

    eval "${BINARY_FILE} ${DOCS_CMDS} '${NAME}'"  > "${DOCS_DIR}/${DOC_MD}"
}


function module_docs {
    echo "Writing module docs"
    if test -d ./modules; then
        for dir in ./modules/*; do
            mkdir -p "${dir}/${DOCS_DIR}"
            local base=$(basename "${dir}")
            eval "${BINARY_FILE} ${DOCS_CMDS} '${NAME} - ${base}' ${dir}"  >> "${dir}/${DOCS_DIR}/${DOC_MD}"
        done
    else
        echo "No modules directory, skipping."
    fi
}


setup
main_docs
module_docs



