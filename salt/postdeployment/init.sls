{% if grains.get('cleanup_secrets') == true %}
include:
  - .remove_grains
  - .remove_salt_logs
{% endif %}

# dummy state to always include at least one state
postdeployment ran:
  cmd.run:
    - name: echo "postdeployment ran"
