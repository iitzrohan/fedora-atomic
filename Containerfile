ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG SOURCE_ORG="${SOURCE_ORG:-fedora-ostree-desktops}"
ARG BASE_IMAGE="quay.io/${SOURCE_ORG}/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-42}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.14.0-0.rc3.29.fc42.x86_64}"
ARG AKMODS_REGISTRY=ghcr.io/ublue-os
ARG AKMODS_DIGEST=""
ARG AKMODS_NVIDIA_DIGEST=""
ARG BASE_IMAGE_DIGEST=""

FROM scratch AS ctx
COPY / /

FROM ${AKMODS_REGISTRY}/akmods:main-${FEDORA_MAJOR_VERSION}${AKMODS_DIGEST:+@${AKMODS_DIGEST}} AS akmods

FROM ${AKMODS_REGISTRY}/akmods-nvidia-open:main-${FEDORA_MAJOR_VERSION}${AKMODS_NVIDIA_DIGEST:+@${AKMODS_NVIDIA_DIGEST}} AS akmods_nvidia

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}${BASE_IMAGE_DIGEST:+@${BASE_IMAGE_DIGEST}} AS base

ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-42}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.14.0-0.rc3.29.fc42.x86_64}"
ARG BUILD_NVIDIA="${BUILD_NVIDIA:-N}"

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=cache,target=/var/cache \
    --mount=type=cache,target=/var/log \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,from=akmods,src=/rpms/ublue-os,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods_nvidia,src=/rpms,dst=/tmp/akmods-nv-rpms \
    rm -f /usr/bin/chsh && \
    rm -f /usr/bin/lchsh && \
    /ctx/build_files/shared/build.sh

# bootc lint
RUN ["bootc", "container", "lint"]
