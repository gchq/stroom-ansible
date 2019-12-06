# Aliases that are useful for doing things quicker in this repo
#AWS_INVENTORY=~/git_work/stroom-resources/ansible/aws/build/aws_inventory.csv
#alias sshaws='ssh centos@$(echo $(cat $AWS_INVENTORY | fzf) | cut -d "," -f3) -i ~/.ssh/stroom_aws_key.pem'
alias apf='playbook="$(ag -c --depth=1 -G ".*\.yml" "\- name:" ./ | cut -d ":" -f1 | cut -d "." -f1 | fzf)"; ansible-playbook "${playbook}.yml"'

alias ap='ansible-playbook '
alias api='ansible-playbook -i inventory '
alias vault='ansible-vault edit vars/aws_vault.yml' 
