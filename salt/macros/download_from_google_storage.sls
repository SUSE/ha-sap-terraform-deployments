# Install and configure gcloud to download files from google storage accounts
# https://cloud.google.com/sdk/install
{% macro download_from_google_storage(credentials_file, bucket_path, dest_folder) -%}
{% set gcloud_dir = '/root' %}
{% set gcloud_bin_dir = gcloud_dir~'/google-cloud-sdk/bin' %}

install_gcloud:
  cmd.run:
    - name: curl https://sdk.cloud.google.com | bash -s -- '--disable-prompts' '--install-dir={{ gcloud_dir }}'
    - unless: ls {{ gcloud_dir }}/google-cloud-sdk

# The next 2 states are not really needed, but it's good to have gcloud configured in any case
add_gcloud_path:
  file.append:
    - name: /root/.bashrc
    - text: |

        # The next line updates PATH for the Google Cloud SDK.
        if [ -f '{{ gcloud_dir }}/google-cloud-sdk/path.bash.inc' ]; then . '{{ gcloud_dir }}/google-cloud-sdk/path.bash.inc'; fi

        # The next line enables shell command completion for gcloud.
        if [ -f '{{ gcloud_dir }}/google-cloud-sdk/completion.bash.inc' ]; then . '{{ gcloud_dir }}/google-cloud-sdk/completion.bash.inc'; fi
    - require:
      - install_gcloud

restart_shell:
  cmd.run:
    - name: exec $SHELL &
    - require:
      - install_gcloud

# Fix for https://github.com/SUSE/ha-sap-terraform-deployments/issues/669
# gcloud and gsutil don't support python3.4 usage
{%- set python3_version = salt['cmd.run']('python3 --version').split(' ')[1] %}
{%- if salt['pkg.version_cmp'](python3_version, '3.5') < 0 %}
{%- set use_py2 = true %}
{%- else %}
{%- set use_py2 = false %}
{%- endif %}

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
