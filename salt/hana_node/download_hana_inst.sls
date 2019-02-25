download_files:
  cmd.run:
    - name: "aws s3 sync {{ grains['hana_inst_master'] }}
      {{ grains['hana_inst_folder'] }}"
    - onlyif: "aws s3 sync --dryrun {{ grains['hana_inst_master'] }}
      {{ grains['hana_inst_folder'] }} | grep download"

{{ grains['hana_inst_folder'] }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 754
    - file_mode: 755
    - recurse:
      - user
      - group
      - mode
