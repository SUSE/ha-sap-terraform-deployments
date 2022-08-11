# Install and configure gcloud to download files from google storage accounts
# https://cloud.google.com/sdk/install
{% macro download_from_google_storage(credentials_file, bucket_path, dest_folder) -%}
{% set gcloud_inst_dir = '/opt' %}
{% set gcloud_dir = gcloud_inst_dir~'/google-cloud-sdk' %}
{% set gcloud_bin_dir = '/usr/local/bin' %}

# Fix for https://github.com/SUSE/ha-sap-terraform-deployments/issues/669
# gcloud and gsutil don't support python3.4 usage
{%- set python3_version = salt['cmd.run']('python3 --version').split(' ')[1] %}
{%- if salt['pkg.version_cmp'](python3_version, '3.5') < 0 %}
{%- set use_py2 = true %}
{%- else %}
{%- set use_py2 = false %}
{%- endif %}

install_gcloud:
  cmd.run:
    - name: export CLOUDSDK_PYTHON; curl https://sdk.cloud.google.com | bash -s -- '--disable-prompts' '--install-dir={{ gcloud_inst_dir }}'
    {%- if use_py2 %}
    - env:
      - CLOUDSDK_PYTHON: python2.7
    {%- endif %}
    - unless: ls {{ gcloud_dir }}

/etc/profile.d/google-cloud-sdk.completion.sh:
  file.symlink:
  - target: {{ gcloud_dir }}/completion.bash.inc

{{ gcloud_bin_dir }}/gcloud:
  file.symlink:
  - target: {{ gcloud_dir }}/bin/gcloud

{{ gcloud_bin_dir }}/gsutil:
  file.symlink:
  - target: {{ gcloud_dir }}/bin/gsutil

configure_gcloud_credentials:
  cmd.run:
    - name: {{ gcloud_bin_dir }}/gcloud auth activate-service-account --key-file {{ credentials_file }}
    {%- if use_py2 %}
    - env:
      - CLOUDSDK_PYTHON: python2.7
    {%- endif %}
    - require:
      - install_gcloud

# We cannot just use path_join as converts '//' to '/'
{% set bucket_path = bucket_path.replace('gs://', '') %}
{% set gs_url = 'gs://'~(bucket_path | path_join('*')) %}

download_files_from_gcp:
  cmd.run:
    - name: {{ gcloud_bin_dir }}/gsutil -m cp -r {{ gs_url }} {{ dest_folder }}
    - output_loglevel: quiet
    - hide_output: True
    {%- if use_py2 %}
    - env:
      - CLOUDSDK_PYTHON: python2.7
    {%- endif %}
    - require:
      - install_gcloud

{%- endmacro %}
