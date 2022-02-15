PROFILE_AWS_REGION = us-east-1
TF_WORKSPACE = scc-admin

init:
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform init"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform init

new-workspace:
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform new workspace"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform workspace new $(TF_WORKSPACE)

select-workspace:
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform select workspace"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform workspace select $(TF_WORKSPACE)

plan: init select-workspace
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform plan"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform plan

apply: init select-workspace
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform apply"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform apply

destroy: init select-workspace
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	@echo "Executing terraform destroy"
	@echo "$(shell tput setaf 2)#######################################################################################$(shell tput sgr0)"
	terraform destroy