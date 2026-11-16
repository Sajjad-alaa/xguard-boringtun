#!/bin/sh
set -e

CARGO="${HOME}/.cargo/bin/cargo"
DST="${PWD}/../VPNExtension/BoringTun"
TARGET_DIR="${CARGO_TARGET_DIR:-./target}"

for TARGET in aarch64-apple-darwin aarch64-apple-ios aarch64-apple-ios-sim
do
    echo "${TARGET}"
    ${CARGO} build --features bindgen --lib --release --target ${TARGET}
done

rm -f -r ${TARGET_DIR}/uniffi
${CARGO} run --features bindgen --release --bin uniffi-bindgen -- \
    --xcframework --headers --modulemap --swift-sources \
    ${TARGET_DIR}/aarch64-apple-darwin/release/libxguard_boringtun.a ${TARGET_DIR}/uniffi

mkdir -p "${DST}"
mv ${TARGET_DIR}/uniffi/xguard_boringtun.swift ${DST}/
rm -f -r ${DST}/xguard_boringtun.xcframework
xcrun xcodebuild -create-xcframework \
    -library ${TARGET_DIR}/aarch64-apple-darwin/release/libxguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -library ${TARGET_DIR}/aarch64-apple-ios/release/libxguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -library ${TARGET_DIR}/aarch64-apple-ios-sim/release/libxguard_boringtun.a \
    -headers ${TARGET_DIR}/uniffi \
    -output ${DST}/xguard_boringtun.xcframework
mv ${TARGET_DIR}/uniffi/xguard_boringtunFFI.h ${DST}/
