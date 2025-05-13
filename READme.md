# To safely use both workflows:
- For normal development:

Push to the main branch to trigger terraform.yml and create/update infrastructure

- When you want to destroy infrastructure:

Create and push to a destroy branch to trigger terraform-destroy.yml

OR manually trigger the destroy workflow from the GitHub Actions UI

- To prevent accidental creation after destruction:

After destroying infrastructure, you might want to modify terraform.yml to prevent it from automatically running on the next push

You could add a condition or comment out the workflow temporarily

# Best practice for managing this:
Add a safeguard to your terraform.yml workflow to prevent it from running if a destroy operation is in progress:

jobs:
  check-destroy-status:
    runs-on: ubuntu-latest
    outputs:
      should_continue: ${{ steps.check.outputs.should_continue }}
    steps:
      - id: check
        run: |
          # Check if destroy workflow is running
          DESTROY_RUNNING=$(gh api repos/${{ github.repository }}/actions/runs?status=in_progress | jq '.workflow_runs[] | select(.name=="Terraform Destroy") | .id' | wc -l)
          if [ "$DESTROY_RUNNING" -gt "0" ]; then
            echo "::set-output name=should_continue::false"
            echo "Destroy workflow is running, skipping apply"
          else
            echo "::set-output name=should_continue::true"
          fi
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  terraform-apply:
    needs: check-destroy-status
    if: needs.check-destroy-status.outputs.should_continue == 'true'
    runs-on: ubuntu-latest
    # Rest of your job...

