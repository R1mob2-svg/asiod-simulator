# ASIOD Simulator Manifest

## Status

Activated as a safe GitHub simulator.

## Repository

`R1mob2-svg/asiod-simulator`

## Safety boundaries

- No real Node 0 archive is stored in this repo.
- No real recipient keys are stored in this repo.
- No real private release source is stored in this repo.
- No destructive cleanup command is included.
- Public CI only runs fixture-based dry-run verification.

## Proven workflow

1. Create sample ASIOD release fixture.
2. Build full Node 0 master archive.
3. Build restricted brother archive from a separate staging area.
4. Verify brother archive contains only approved six fields and runtime files.
5. Produce simulated sealed outputs using checksums.
6. Fail CI if forbidden private markers appear in restricted output.

## Why this matters

Encrypting the same archive twice does not create restricted access. This simulator enforces the correct separation: master and brother packages are built from different source sets before sealing.

## Next real-world upgrade path

For real private usage, keep the public simulator as proof logic only. Run the real sealing flow locally or in a private hardened environment where recipient public keys and source material are present. Then publish only receipts: manifest hash, archive content listing, and verification output.
