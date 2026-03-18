# Publishing to the Terraform Registry

This guide covers how to publish the root module to the [Terraform Registry](https://registry.terraform.io/).

## Prerequisites

1. **GitHub repository naming** — The Terraform Registry requires the repo name to follow `terraform-<PROVIDER>-<NAME>`. For this module, the ideal names are:
   - `terraform-aws-eks-ray` (recommended)
   - `terraform-aws-ray-platform`

   If renaming the repo is not practical, the module can still be published from a subdirectory using the `//terraform` source path.

2. **GitHub releases with semver tags** — The registry requires tags in the format `vX.Y.Z`. The `release-please` workflow in this repo handles this automatically on merge to `main`.

3. **`versions.tf` in the module root** — Already present with `required_version` and `required_providers`.

## Steps

### 1. Connect to the Registry

1. Go to [registry.terraform.io](https://registry.terraform.io/) and sign in with your GitHub account.
2. Click **Publish** → **Module**.
3. Select the GitHub organization and repository.
4. The registry will automatically detect tagged releases and make them available.

### 2. Verify the Module Structure

The registry expects any of:
- A module at the repo root
- A module in a subdirectory (referenced via `//terraform` in the source path)

This repo uses the subdirectory pattern. Consumers reference it as:

```hcl
module "ray_eks_cluster" {
  source  = "ambicuity/eks-ray/aws"
  version = "~> 1.0"

  # ... variables ...
}
```

Or via Git directly (works without registry publishing):

```hcl
module "ray_eks_cluster" {
  source = "git::https://github.com/ambicuity/terraform-aws-eks-ray.git//terraform?ref=v1.0.0"

  # ... variables ...
}
```

### 3. Create a Release

With `release-please` configured:

1. Push commits to `main` using [Conventional Commits](https://www.conventionalcommits.org/) format:
   - `feat:` for new features (bumps minor version)
   - `fix:` for bug fixes (bumps patch version)
   - `feat!:` or `BREAKING CHANGE:` for breaking changes (bumps major version)

2. `release-please` creates a release PR automatically.
3. Merge the release PR to create the GitHub Release and tag.
4. The Terraform Registry picks up the new tag automatically.

### 4. Generate Documentation

The `terraform-docs` workflow automatically updates `README.md` with inputs/outputs tables on PRs that change Terraform source files. This content is displayed on the registry module page.

## Registry-Specific Requirements

| Requirement | Status |
|-------------|--------|
| `versions.tf` with `required_providers` | ✅ Present |
| `variables.tf` with descriptions | ✅ All 29 variables have descriptions |
| `outputs.tf` with descriptions | ✅ All 22 outputs have descriptions |
| README in module directory | ✅ `README.md` |
| Semver-tagged GitHub releases | ✅ v1.0.0 exists; `release-please` handles future releases |
| `main.tf` exists | ✅ Present |

## Alternative: Using a Repo Named `terraform-aws-eks-ray`

If you rename the repo or create a fork:

1. Rename the GitHub repository to `terraform-aws-eks-ray`.
2. Move the module files from your subdirectory to the repo root (already done for this repo).
3. The registry will automatically detect the standard layout.
4. Consumers can then use the simplified source:

```hcl
module "ray_eks_cluster" {
  source  = "ambicuity/eks-ray/aws"
  version = "~> 1.0"
}
```
