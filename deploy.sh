#!/bin/bash
docker push johannweging/leanote:${VERSION}

if [[ "${LEANOTE_VERSION}" == "${LATEST}" ]]; then
    docker tag johannweging/leanote:${LEANOTE_VERSION} johannweging/leanote:latest
    docker push johannweging/leanote:latest
fi
