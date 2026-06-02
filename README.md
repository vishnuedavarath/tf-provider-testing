# tf-provider-testing

Terraform-based Nomad provider test cases collected as small, focused reproductions for specific upstream `hashicorp/terraform-provider-nomad` changes.

## Purpose

This repo keeps standalone Terraform cases under `cases/` so individual provider behaviors can be validated against a local Nomad environment without needing the upstream acceptance test harness.

Most cases are designed to be:

- minimal
- targeted at one upstream PR or behavior
- runnable with ordinary Terraform commands
- independent from each other apart from shared bootstrap state

## Repository Layout

- `bootstrap/`: resolves an existing Nomad ACL token and writes it to local Terraform state for reuse by the cases
- `cases/_template/`: shared example showing the standard remote-state bootstrap pattern
- `cases/pr-*/`: individual Terraform cases for specific provider PRs or behaviors

## Bootstrap Flow

Cases do not hardcode a Nomad token. Instead they read `token_secret_id` from `bootstrap/terraform.tfstate` via `terraform_remote_state`.

The bootstrap config expects an existing Nomad ACL token name and looks up its accessor and secret ID:

- default token name: `tf-provider-testing`
- bootstrap outputs: `token_accessor_id`, `token_secret_id`

Initialize or refresh the bootstrap state first:

```sh
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply
```

If you need a different token name:

```sh
terraform -chdir=bootstrap apply -var='token_name=your-token-name'
```

## Running a Case

Most cases follow the same pattern:

```sh
terraform -chdir=cases/pr-582-job-parser-variables init
terraform -chdir=cases/pr-582-job-parser-variables validate
terraform -chdir=cases/pr-582-job-parser-variables apply
```

Destroy a case when finished if it creates persistent Nomad resources:

```sh
terraform -chdir=cases/pr-582-job-parser-variables destroy
```

Some cases are multi-phase or intentionally negative. Check the case directory contents before running them.

## Docker Runner

If your Nomad cluster address and ACL token are already available as environment variables, you can run the repo inside Docker without editing the case providers.

The container setup will:

- use `NOMAD_ADDR` and `NOMAD_TOKEN` from the environment
- export `TF_VAR_bootstrap_token_secret_id` from `NOMAD_TOKEN`
- initialize and apply `bootstrap/` on container start by default
- include both the Terraform CLI and the Nomad CLI for cases that use `local-exec`

Build the image:

```sh
docker build -t tf-provider-testing .
```

Start an interactive shell in the container:

```sh
docker run --rm -it \
  -e NOMAD_ADDR \
  -e NOMAD_TOKEN \
  -v "$PWD":/workspace \
  tf-provider-testing
```

Or use Compose:

```sh
docker compose run --rm terraform
```

Run a specific case directly:

```sh
docker compose run --rm terraform terraform -chdir=cases/pr-579-node-datasources init
docker compose run --rm terraform terraform -chdir=cases/pr-579-node-datasources apply
```

If you do not want bootstrap to run automatically on container start, set `BOOTSTRAP_ON_START=0`.

## Notable Case Types

- regular resource and data source round-trip cases
- validation failure cases
- ephemeral resource cases that write apply-time artifacts such as JSON summaries or token files
- multi-step behavior cases such as preserve-count flows

## Environment Notes

- Terraform version requirements vary by case. Ephemeral-resource cases require newer Terraform versions than the basic cases.
- A local Nomad environment with ACLs enabled is assumed.
- If Terraform reports development override warnings for `hashicorp/nomad`, that usually means your global Terraform CLI config is pointing at a local provider build.

## Generated Files

Generated Terraform working directories, state, plans, and runtime secret artifacts are ignored through the root `.gitignore`.
