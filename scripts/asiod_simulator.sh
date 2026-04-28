#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/fixtures/asiod_release"
BUILD_DIR="$ROOT_DIR/build/asiod"
DIST_DIR="$ROOT_DIR/dist"
MASTER_STAGE="$BUILD_DIR/master_stage"
BROTHER_STAGE="$BUILD_DIR/brother_stage"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$MASTER_STAGE/fields" "$BROTHER_STAGE/fields" "$DIST_DIR"

printf 'ASIOD simulator starting...\n'

# Build sample fixture source if it does not exist.
mkdir -p "$FIXTURE_DIR/fields"
for n in 01 02 03 04 05 06 07 08; do
  file="$FIXTURE_DIR/fields/field${n}.bin"
  if [[ ! -f "$file" ]]; then
    printf 'sample field %s\n' "$n" > "$file"
  fi
done

printf 'NODE0_PRIVATE_ONLY\n' > "$FIXTURE_DIR/node0_private.key.sample"
printf '#!/usr/bin/env bash\nprintf "running restricted engine\\n"\n' > "$FIXTURE_DIR/run_engine.sh"
chmod +x "$FIXTURE_DIR/run_engine.sh"
printf '{"name":"ASIOD simulated runtime","restricted_fields":["field01","field02","field03","field04","field05","field06"]}\n' > "$FIXTURE_DIR/runtime_manifest.json"

# Master package: all fixture source.
cp -R "$FIXTURE_DIR/." "$MASTER_STAGE/"
tar -czf "$DIST_DIR/ASIOD_MASTER_N0.tar.gz" -C "$MASTER_STAGE" .

# Brother package: only the approved six fields and runtime files.
for n in 01 02 03 04 05 06; do
  cp "$FIXTURE_DIR/fields/field${n}.bin" "$BROTHER_STAGE/fields/"
done
cp "$FIXTURE_DIR/run_engine.sh" "$BROTHER_STAGE/"
cp "$FIXTURE_DIR/runtime_manifest.json" "$BROTHER_STAGE/"
tar -czf "$DIST_DIR/ASIOD_BROTHER_ACCESS.tar.gz" -C "$BROTHER_STAGE" .

printf 'Verifying brother archive contents...\n'
tar -tzf "$DIST_DIR/ASIOD_BROTHER_ACCESS.tar.gz" | sort | tee "$DIST_DIR/brother_contents.txt"

if tar -tzf "$DIST_DIR/ASIOD_BROTHER_ACCESS.tar.gz" | grep -E 'node0|field07|field08|private|key'; then
  printf 'FAIL: restricted archive contains forbidden content.\n' >&2
  exit 1
fi

# Simulated sealed outputs. These are not real encryption; they are proof placeholders for CI.
sha256sum "$DIST_DIR/ASIOD_MASTER_N0.tar.gz" > "$DIST_DIR/ASIOD_MASTER_N0.tar.gz.simulated.gpg"
sha256sum "$DIST_DIR/ASIOD_BROTHER_ACCESS.tar.gz" > "$DIST_DIR/ASIOD_BROTHER_ACCESS.tar.gz.simulated.gpg"

cat > "$DIST_DIR/asiod_simulation_manifest.json" <<JSON
{
  "simulator": "asiod-simulator",
  "mode": "safe_dry_run",
  "master_archive": "ASIOD_MASTER_N0.tar.gz",
  "brother_archive": "ASIOD_BROTHER_ACCESS.tar.gz",
  "brother_restriction": "fields_01_to_06_only_plus_runtime_files",
  "destructive_cleanup": "not_supported_in_repo",
  "real_secret_material": false
}
JSON

printf 'PASS: simulator completed safely. Outputs written to %s\n' "$DIST_DIR"
