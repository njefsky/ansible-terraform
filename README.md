# ansible-terraform

## prerequisites

You need to install the following packages.

yum install ansible wget -y

## vault

In group_vars/all/vault.yml you need to add the following variables.

```yaml
  ---

  public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  aws_access_key_id: "AKXXXXXXXXXXXXXXXXXXXX"
  aws_secret_access_key: "9hVXXXXXXXXXXXXXXXXXXXXX"

  ...
```

encrypt the file with
```bash
ansible-vault encrypt group_vars/all/vault.yml
 New Vault password:
 Confirm New Vault password:
```

After this you can run your playbook ass follows.

```bash
ansible-playbook playbook.yml --key-file /path/to/private/key/id_rsa --ask-vault-pass
 Vault paasword:
```

It will prompt for your password.
