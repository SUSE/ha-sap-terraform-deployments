include:
  - iscsi_srv.registration
  - iscsi_srv.parted
  - iscsi_srv.iscsi_kernel_mod
  - iscsi.target
{% if grains.get('qa_mode') %}
  - iscsi_srv.qa_iscsi
{% else %}
  # Workaround to restart targetcli service
  # This need to be fixed in the formula
  - iscsi_srv.targetcli
{% endif %}
