# PR-628: `nomad_csi_volume` Legacy Secrets — Backward Compatibility Testing

## Purpose

This test case validates that migrating the `nomad_csi_volume` resource from the legacy SDK v2 implementation to the new Terraform Plugin Framework **does not break existing users** who have the deprecated `secrets` attribute in their state and configuration.

The key concern: users upgrading the provider version should experience **zero state drift** and no forced replacement of their CSI volumes.

---

## What This Tests

| Scenario | Description |
|----------|-------------|
| State preservation | Legacy `secrets` attribute remains readable from existing state after provider upgrade |
| No-op plan | Running `terraform plan` after upgrading the provider produces no changes |
| Apply idempotency | Repeated applies don't modify the resource |
| Secrets in state | The deprecated `secrets` map is retained in state (not wiped) |
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

### 2. Bootstrap State

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

### 3. Terraform Version

Requires Terraform >= 1.11.0 (for `check` blocks).

### 4. Provider Versions

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
terraform output csi_volume_legacy_secrets_metadata

# 4. Confirm secrets are in state
terraform state show nomad_csi_volume.legacy_secrets | grep -A5 secrets
```

**Expected**: Resource created, secrets stored in state, all check assertions pass.

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
terraform state show nomad_csi_volume.legacy_secrets

# 2. Verify outputs still work
terraform output csi_volume_legacy_secrets_metadata

# 3. Run the built-in check assertions
terraform plan  # check blocks run during plan
```

**Expected**: All `check` assertions pass, outputs are populated, secrets remain in state.

### Phase 5: Modify a Non-Secret Field

```bash
# 1. Change the volume name
terraform apply -var='volume_name=pr-628-renamed-volume' -auto-approve

# 2. Verify only the name changed, secrets untouched
terraform state show nomad_csi_volume.legacy_secrets
```

**Expected**: Only the name field updates. Secrets and other fields remain stable.

### Phase 6: Destroy and Recreate

```bash
# 1. Destroy with the new provider
terraform destroy -auto-approve

# 2. Re-apply from scratch
terraform apply -auto-approve

# 3. Verify new resource works identically
terraform plan
```

**Expected**: Clean destroy, clean create, no residual drift.

---

## Regression Indicators

Any of these indicate a backward compatibility issue:

| Symptom | Likely Cause |
|---------|--------------|
| Plan shows `secrets` as changed | State schema migration bug |
| Plan shows resource replacement (`-/+`) | Schema change forces new resource |
| `secrets` is `null` after upgrade | Read function doesn't populate legacy field |
| `capability` block shows diff | Set/list ordering inconsistency |
| `capacity_min` shows diff | String normalization difference (e.g., `"10MiB"` vs `"10 MiB"`) |
| Check assertions fail | Output attributes renamed or typed differently |

---

## Cleanup

```bash
terraform destroy -auto-approve
```

---

## Notes

- The `secrets` attribute is **deprecated** in the new provider but must continue to function for existing state.
- New deployments should use the `secrets_wo` (write-only) attribute instead — tested separately in `pr-628-csi-volume-write-only/`.
- This case intentionally uses `sensitive = true` on the secrets variable to mirror real-world usage.
