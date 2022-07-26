# The base environment should already come with the salt-standalone-formulas-configuration >= 3002.2-46.1 rpm.
# We set it here anyway to be more resilient.
/etc/salt/minion.d/environment_base.conf:
  file.managed:
    - contents: |
        file_roots:
          base:
            - /srv/salt
            - /usr/share/salt-formulas/states

/etc/salt/minion.d/environment_predeployment.conf:
  file.managed:
    - contents: |
        file_roots:
          predeployment:
            - /srv/salt
            - /usr/share/salt-formulas/states

/etc/salt/minion.d/environment_postdeployment.conf:
  file.managed:
    - contents: |
        file_roots:
          postdeployment:
            - /srv/salt
            - /usr/share/salt-formulas/states

# prevent "[WARNING ] top_file_merging_strategy is set to 'merge' and multiple top files were found."
/etc/salt/minion.d/top_file_merging_strategy.conf:
  file.managed:
    - contents: |
        top_file_merging_strategy: same

# Old module.run style will be deprecated after sodium release
/etc/salt/minion.d/use_superseded.conf:
  file.managed:
    - contents: |
        use_superseded:
          - module.run

minion_service:
  service.dead:
    - name: salt-minion
    - enable: False
