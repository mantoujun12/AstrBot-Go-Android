#!/usr/bin/env bash
# Export the PRoot base rootfs from runtime/Dockerfile.base.
#
# Prerequisites:
#   - Docker with the buildx plugin.
#   - On x86_64 hosts, qemu user emulation is required first:
#       docker run --privileged --rm tonistiigi/binfmt --install arm64
#   - zstd and sha256sum on the host.
#
# Final release packaging automation lives in GitHub Actions; this script is
# for local development and verification only.
set -euo pipefail

OUTPUT_DIR="${1:-dist}"
FORCE="${2:-}"

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [ -e "$OUTPUT_DIR" ] && [ "$FORCE" != "--force" ]; then
    echo "refusing to overwrite existing '$OUTPUT_DIR' (pass --force)" >&2
    exit 1
fi
mkdir -p "$OUTPUT_DIR"

staging="$OUTPUT_DIR/rootfs-tree"
echo "==> Building linux/arm64 image and exporting rootfs tree to $staging"
docker buildx build \
    --platform linux/arm64 \
    -f "$repo_root/runtime/Dockerfile.base" \
    --output "type=local,dest=$staging" \
    "$repo_root"

echo "==> Creating rootfs.tar (reproducible-ish: sorted, numeric root ownership)"
tar -C "$staging" \
    --sort=name --owner=0 --group=0 --numeric-owner \
    --preserve-permissions \
    -cf "$OUTPUT_DIR/rootfs.tar" .

echo "==> Compressing with zstd -19"
zstd -19 -f -q "$OUTPUT_DIR/rootfs.tar" -o "$OUTPUT_DIR/rootfs.tar.zst"

echo "==> Writing sha256"
sha256sum "$OUTPUT_DIR/rootfs.tar.zst" | awk '{print $1}' > "$OUTPUT_DIR/rootfs.tar.zst.sha256"

DEBIAN_RELEASE="trixie"
PYTHON_VERSION="3.12.11"
UV_VERSION="0.9.5"
SHA256="$(cat "$OUTPUT_DIR/rootfs.tar.zst.sha256")"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "==> Writing manifest.json stub"
cat > "$OUTPUT_DIR/manifest.json" <<EOF
{
  "schema": 1,
  "baseId": "TODO-assigned-by-release-pipeline",
  "debianRelease": "$DEBIAN_RELEASE",
  "pythonVersion": "$PYTHON_VERSION",
  "uvVersion": "$UV_VERSION",
  "sha256": "$SHA256",
  "timestamp": "$TIMESTAMP"
}
EOF

rm -rf "$staging"
echo "==> Done: $OUTPUT_DIR/rootfs.tar.zst (+ .sha256, manifest.json)"
