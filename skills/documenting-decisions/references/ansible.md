# Ansible task documentation

Place documentation for an Ansible task in the playbook or role above the task, never inside
file content, templates, or inline variables that get written to the target system. The target
system should receive only the clean, production artifact.

```yaml
# Sets aggressive but safe revalidation interval; deploys update files atomically.
- name: Configure open_file_cache_valid
  ansible.builtin.lineinfile:
    path: /etc/nginx/nginx.conf
    line: "open_file_cache_valid 1s;"
```

Not like this (the comment ends up on the managed host):

```yaml
- name: Configure open_file_cache_valid
  ansible.builtin.copy:
    content: |
      # Revalidate every second; aggressive but safe when deploys update files atomically.
      open_file_cache_valid 1s;
    dest: /etc/nginx/conf.d/cache.conf
```

The same applies to `template` tasks: explanatory comments belong in the playbook or role
`README`, not in the `.j2` file, unless the template itself is a config file that warrants
inline comments for the operators who read it on the host.
