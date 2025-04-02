terragrunt run-all init
cd mosip-dev-infra
rm -rf .terragrunt-cache
terragrunt apply -auto-approve --terragrunt-non-interactive --target=module.vcn
terragrunt apply -auto-approve --terragrunt-non-interactive

cd ../mosip-dev-app
rm -rf .terragrunt-cache
terragrunt apply -auto-approve --terragrunt-non-interactive