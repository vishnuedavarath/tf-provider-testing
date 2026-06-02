# PR-628: `nomad_csi_volume_registration` Legacy Secrets — Backward Compatibility Testing

## Purpose

This test case validates that migrating the `nomad_csi_volume_registration` resource from the legacy SDK v2 implementation to the new Terraform Plugin Framework **does not break existing users** who have the deprecated `secrets` attribute in their state and configuration.

The `nomad_csi_volume_registration` resource differs from `nomad_csi_volume` in that it **registers** a pre-existing external volume rather than creating one. It has additional attributes like `external_id` and `deregister_on_destroy` that must also survive the migration.

---

## What This Tests

| Scenario | Description |
|----------|-------------|
| State preservation | Legacy `secrets` attribute remains readable from existing state after provider upgrade |
| No-op plan | Running `terraform plan` after upgrading the provider produces no changes |
| Apply idempotency | Repeated applies don't modify the resource |
| Secrets in state | The deprecated `secrets` map is retained in state (not wiped) |
| `external_id` stability | The external volume identifier is preserved across upgrades |
| `deregister_on_destroy` flag | Boolean flag behavior is consistent |
| Capability block stability | `capability` blocks are read/written consistently |
| Computed fields | `capacity`, `controller_required`, etc. remain consistent |

---

## Prerequisites

### 1. Running Nomad Cluster with CSI Plugin

A Nomad cluster must be running with a CSI plugin registered. The default test uses the `hostpath` plugin.

```bash
# Verify CSI plugin is available
nomad plugin status hostpath
```

If using a different plugin, override with:

```bash
export TF_VAR_plugin_id="your-plugin-id"
```

### 2. Pre-existing External Volume

The `nomad_csi_volume_registration` resource registers an **already-existing** volume from the storage provider. For testing with the `hostpath` plugin, the external ID can be arbitrary (the plugin handles it). For real storage backends, ensure the volume exists externally first.

The default `external_id` is `pr-628-legacy-external-id`.

### 3. Bootstrap State

The bootstrap stack must be initialized and applied so the Nomad provider can authenticate:

```bash
terraform -chdir=../../bootstrap init
terraform -chdir=../../bootstrap apply
```

Ensure `NOMAD_ADDR` and `NOMAD_TOKEN` environment variables are set:

```bash
export NOMAD_ADDR="http://localhost:4646"
export NOMAD_TOKEN="<your-management-token>"
```

### 4. Terraform Version

Requires Terraform >= 1.11.0 (for `check` blocks).

### 5. Provider Versions

You need **two** versions of the Nomad provider:
- **Old version**: The last released SDK v2 version (before PR-628)
- **New version**: The framework-based build from PR-628

---

## Test Steps

### Phase 1: Establish Baseline with Old Provider

This simulates an existing user's state before they upgrade.

```bash
# 1. Pin to the old (SDK v2) provider version in providers.tf
#    e.g., version = "2.4.0" (last version before migration)

# 2. Initialize and apply
terraform init
terraform apply -auto-approve

# 3. Verify state was created successfully
terraform show
terraform output csi_volume_registration_legacy_secrets_metadata

# 4. Confirm secrets are in state
terraform state show nomad_csi_volume_registration.legacy_secrets | grep -A5 secrets

# 5. Confirm external_id and deregister_on_destroy
terraform state show nomad_csi_volume_registration.legacy_secrets | grep -E "external_id|deregister"
```

**Expected**: Resource registered, secrets stored in state, all check assertions pass.

### Phase 2: Upgrade Provider (Simulate User Upgrade)

```bash
# 1. Update providers.tf to use the new framework-based provider
#    Remove version pin or point to local dev override

# 2. Re-initialize to pick up the new provider binary
terraform init -upgrade

# 3. Run plan — this is the critical test
terraform plan
```

**Expected**: `No changes. Your infrastructure matches the configuration.`

If the plan shows any changes, this is a **backward compatibility regression**.

### Phase 3: Verify Apply Idempotency

```bash
# 1. Apply (should be a no-op)
terraform apply -auto-approve

# 2. Plan again
terraform plan
```

**Expected**: Both operations report no changes.

### Phase 4: Verify State Integrity Post-Upgrade

```bash
# 1. Check secrets are still in state
terraform state show nomad_csi_volume_registration.legacy_secrets

# 2. Verify outputs still work
terraform output csi_volume_registration_legacy_secrets_metadata

# 3. Confirm external_id persisted correctly
terraform output -json csi_volume_registration_legacy_secrets_metadata | jq .external_id

# 4. Run the built-in check assertions
terraform plan  # check blocks run during plan
```

**Expected**: All `check` assertions pass, outputs are populated, secrets and external_id remain in state.

### Phase 5: Modify a Non-Secret Field

```bash
# 1. Change the volume name
terraform apply -var='volume_name=pr-628-renamed-registration' -auto-approve

# 2. Verify only the name changed, secrets and external_id untouched
terraform state show nomad_csi_volume_registration.legacy_secrets
```

**Expected**: Only the name field updates. Secrets, external_id, and other fields remain stable.

### Phase 6: Toggle `deregister_on_destroy`

```bash
# 1. Flip the deregister flag
terraform apply -var='deregister_on_destroy=false' -auto-approve

# 2. Verify only that flag changed
terraform state show nomad_csi_volume_registration.legacy_secrets | grep deregister
```

**Expected**: Only `deregister_on_destroy` changes. No resource replacement.

### Phase 7: Destroy and Recreate

```bash
# 1. Destroy with the new provider (ensure deregister_on_destroy=true first)
terraform apply -var='deregister_on_destroy=true' -auto-approve
terraform destroy -auto-approve

# 2. Re-apply from scratch
terraform apply -auto-approve

# 3. Verify new resource works identically
terraform plan
```

**Expected**: Clean deregister, clean re-register, no residual drift.

---

## Regression Indicators

Any of these indicate a backward compatibility issue:

| Symptom | Likely Cause |
|---------|--------------|
| Plan shows `secrets` as changed | State schema migration bug |
| Plan shows resource replacement (`-/+`) | Schema change forces new resource |
| `secrets` is `null` after upgrade | Read function doesn't populate legacy field |
| `external_id` shows diff | Field not mapped correctly in new schema |
| `deregister_on_destroy` forces replacement | Incorrectly marked as ForceNew |
| `capability` block shows diff | Set/list ordering inconsistency |
| `capacity_min` shows diff | String normalization difference (e.g., `"10MiB"` vs `"10 MiB"`) |
| Check assertions fail | Output attributes renamed or typed differently |

---

## Differences from `nomad_csi_volume`

| Attribute | `nomad_csi_volume` | `nomad_csi_volume_registration` |
|-----------|-------------------|-------------------------------|
| `external_id` | Not used (volume is created) | Required (references existing volume) |
| `deregister_on_destroy` | N/A | Controls whether volume is deregistered on destroy |
| `clone_id` | Supported | Not applicable |
| Destroy behavior | Deletes the volume | Optionally deregisters (volume persists externally) |

---

## Cleanup

```bash
terraform destroy -auto-approve
```

If `deregister_on_destroy` was set to `false`, the volume registration may persist in Nomad:

```bash
nomad volume deregister -type=csi pr-628-legacy-secrets-registration
```

---

## Notes

- The `secrets` attribute is **deprecated** in the new provider but must continue to function for existing state.
- New deployments should use the `secrets_wo` (write-only) attribute instead — tested separately in `pr-628-csi-volume-registration-write-only/`.
- This case intentionally uses `sensitive = true` on the secrets variable to mirror real-world usage.
- The `external_id` is a registration-specific concern — ensure it roundtrips through state without modification.
