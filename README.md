# ASIOD Simulator

Safe GitHub-hosted simulator for the ASIOD archive split workflow.

This repo contains no private Node 0 material, no real keys, and no live secrets. It proves the workflow shape safely:

1. build a full Node 0 master archive from sample fixture files;
2. build a brother-safe six-field restricted archive from only approved files;
3. verify the restricted archive contents before sealing;
4. simulate sealed outputs in CI without exposing real material;
5. block public-runner execution from touching real private source data.

## Important correction

The brother archive must not be produced from the same full archive as Node 0.

Correct model:

- `ASIOD_MASTER_N0.tar.gz.simulated.gpg` represents the private Node 0 archive.
- `ASIOD_BROTHER_ACCESS.tar.gz.simulated.gpg` represents a separate restricted archive containing only fields `01` to `06`, `run_engine.sh`, and `runtime_manifest.json`.

## Run locally

```bash
chmod +x scripts/asiod_simulator.sh
bash scripts/asiod_simulator.sh
```

Outputs are written to `dist/`.

## What this proves

The simulator proves that the brother access package is built from a separate restricted staging area, not from the master archive. That is the whole point. Same archive to both recipients equals fake restriction. Separate archive equals real containment.

## GitHub Actions

The included workflow runs the simulator on push and pull request. It checks archive contents and fails if restricted output contains forbidden private markers.
