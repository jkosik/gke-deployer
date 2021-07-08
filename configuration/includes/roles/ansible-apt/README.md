# ansible-apt

This role should help you manage APT parameters for your ubuntu installation.

Yet it just disables/enables unattended updates.

## Role Variables

  - `apt_unattended_updates_state`: `disabled` (default) or `enabled`. BEWARE! If you don't change the default behavior, this role will DISABLE unattended updates on your system.
  - `apt_extra_repositories`: a list of dicts with extra repos. Default unset.
  - `apt_pinning`: list of dicts for pinning packages. Limited support yet. Default unset.

## Example playbook

```
- hosts: myhosts
  vars:
    - apt_unattended_updates_state: "disabled"
    - apt_extra_repositories:
      - { repo: "deb http://mz.clouds.archive.ubuntu.com/ubuntu artful main universe" }
    - apt_pinning:
      - { package: "389-*", pin: "release", repo: "artful", prio: 999 }
  roles:
    - ansible-apt
```

## Tests

This role is tested only for playability with default parameters, and ansible-linted.
