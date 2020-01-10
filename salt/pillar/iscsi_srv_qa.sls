iscsi:
  target:
    pkgs:
      wanted:
        - targetcli-fb-common
        - python3-targetcli-fb
        - yast2-iscsi-lio-server
  config:
    data:
      lio:
        fabric_modules: []
        storage_objects:
          sde:
            alua_tpgs:
              sde_alua_tpgs:
                alua_access_state: 0
                alua_access_status: 0
                alua_access_type: 3
                alua_support_active_nonoptimized: 1
                alua_support_active_optimized: 1
                alua_support_offline: 1
                alua_support_standby: 1
                alua_support_transitioning: 1
                alua_support_unavailable: 1
                alua_write_metadata: 0
                implicit_trans_secs: 0
                name: "default_tg_pt_gp"
                nonop_delay_msecs: 100
                preferred: 0
                tg_pt_gp_id: 0
                trans_delay_msecs: 0
            attributes:
              block_size: 512
              emulate_3pc: 1
              emulate_caw: 1
              emulate_dpo: 1
              emulate_fua_read: 1
              emulate_fua_write: 1
              emulate_model_alias: 1
              emulate_pr: 1
              emulate_rest_reord: 0
              emulate_tas: 1
              emulate_tpu: 0
              emulate_tpws: 0
              emulate_ua_intlck_ctrl: 0
              emulate_write_cache: 0
              enforce_pr_isids: 1
              force_pr_aptpl: 0
              is_nonrot: 1
              max_unmap_block_desc_count: 0
              max_unmap_lba_count: 0
              max_write_same_len: 65535
              optimal_sectors: 256
              pi_prot_format: 0
              pi_prot_type: 0
              pi_prot_verify: 0
              queue_depth: 64
              unmap_granularity: 0
              unmap_granularity_alignment: 0
              unmap_zeroes_data: 0
            dev: {{ grains['iscsidev'] }}5
            name: "sde"
            plugin: "block"
            readonly: false
            write_back: false
            wwn: "c2577ab8-f43e-402f-97b4-76b15e0bf890"
          sdd:
            alua_tpgs:
              sde_alua_tpgs:
                alua_access_state: 0
                alua_access_status: 0
                alua_access_type: 3
                alua_support_active_nonoptimized: 1
                alua_support_active_optimized: 1
                alua_support_offline: 1
                alua_support_standby: 1
                alua_support_transitioning: 1
                alua_support_unavailable: 1
                alua_write_metadata: 0
                implicit_trans_secs: 0
                name: "default_tg_pt_gp"
                nonop_delay_msecs: 100
                preferred: 0
                tg_pt_gp_id: 0
                trans_delay_msecs: 0
            attributes:
              block_size: 512
              emulate_3pc: 1
              emulate_caw: 1
              emulate_dpo: 1
              emulate_fua_read: 1
              emulate_fua_write: 1
              emulate_model_alias: 1
              emulate_pr: 1
              emulate_rest_reord: 0
              emulate_tas: 1
              emulate_tpu: 0
              emulate_tpws: 0
              emulate_ua_intlck_ctrl: 0
              emulate_write_cache: 0
              enforce_pr_isids: 1
              force_pr_aptpl: 0
              is_nonrot: 1
              max_unmap_block_desc_count: 0
              max_unmap_lba_count: 0
              max_write_same_len: 65535
              optimal_sectors: 256
              pi_prot_format: 0
              pi_prot_type: 0
              pi_prot_verify: 0
              queue_depth: 64
              unmap_granularity: 0
              unmap_granularity_alignment: 0
              unmap_zeroes_data: 0
            dev: {{ grains['iscsidev'] }}4
            name: "sdd"
            plugin: "block"
            readonly: false
            write_back: false
            wwn: "9e8d8049-3538-41cb-94e6-6dbd2f1cf093"
          sdc:
            alua_tpgs:
              sde_alua_tpgs:
                alua_access_state: 0
                alua_access_status: 0
                alua_access_type: 3
                alua_support_active_nonoptimized: 1
                alua_support_active_optimized: 1
                alua_support_offline: 1
                alua_support_standby: 1
                alua_support_transitioning: 1
                alua_support_unavailable: 1
                alua_write_metadata: 0
                implicit_trans_secs: 0
                name: "default_tg_pt_gp"
                nonop_delay_msecs: 100
                preferred: 0
                tg_pt_gp_id: 0
                trans_delay_msecs: 0
            attributes:
              block_size: 512
              emulate_3pc: 1
              emulate_caw: 1
              emulate_dpo: 1
              emulate_fua_read: 1
              emulate_fua_write: 1
              emulate_model_alias: 1
              emulate_pr: 1
              emulate_rest_reord: 0
              emulate_tas: 1
              emulate_tpu: 0
              emulate_tpws: 0
              emulate_ua_intlck_ctrl: 0
              emulate_write_cache: 0
              enforce_pr_isids: 1
              force_pr_aptpl: 0
              is_nonrot: 1
              max_unmap_block_desc_count: 0
              max_unmap_lba_count: 0
              max_write_same_len: 65535
              optimal_sectors: 256
              pi_prot_format: 0
              pi_prot_type: 0
              pi_prot_verify: 0
              queue_depth: 64
              unmap_granularity: 0
              unmap_granularity_alignment: 0
              unmap_zeroes_data: 0
            dev: {{ grains['iscsidev'] }}3
            name: "sdc"
            plugin: "block"
            readonly: false
            write_back: false
            wwn: "6e92776f-5592-4941-9f8f-b6c297840bdd"
          sdb:
            alua_tpgs:
              sde_alua_tpgs:
                alua_access_state: 0
                alua_access_status: 0
                alua_access_type: 3
                alua_support_active_nonoptimized: 1
                alua_support_active_optimized: 1
                alua_support_offline: 1
                alua_support_standby: 1
                alua_support_transitioning: 1
                alua_support_unavailable: 1
                alua_write_metadata: 0
                implicit_trans_secs: 0
                name: "default_tg_pt_gp"
                nonop_delay_msecs: 100
                preferred: 0
                tg_pt_gp_id: 0
                trans_delay_msecs: 0
            attributes:
              block_size: 512
              emulate_3pc: 1
              emulate_caw: 1
              emulate_dpo: 1
              emulate_fua_read: 1
              emulate_fua_write: 1
              emulate_model_alias: 1
              emulate_pr: 1
              emulate_rest_reord: 0
              emulate_tas: 1
              emulate_tpu: 0
              emulate_tpws: 0
              emulate_ua_intlck_ctrl: 0
              emulate_write_cache: 0
              enforce_pr_isids: 1
              force_pr_aptpl: 0
              is_nonrot: 1
              max_unmap_block_desc_count: 0
              max_unmap_lba_count: 0
              max_write_same_len: 65535
              optimal_sectors: 256
              pi_prot_format: 0
              pi_prot_type: 0
              pi_prot_verify: 0
              queue_depth: 64
              unmap_granularity: 0
              unmap_granularity_alignment: 0
              unmap_zeroes_data: 0
            dev: {{ grains['iscsidev'] }}2
            name: "sdb"
            plugin: "block"
            readonly: false
            write_back: false
            wwn: "7186083b-19a9-4698-ba2c-e458615de6de"
          sda:
            alua_tpgs:
              sde_alua_tpgs:
                alua_access_state: 0
                alua_access_status: 0
                alua_access_type: 3
                alua_support_active_nonoptimized: 1
                alua_support_active_optimized: 1
                alua_support_offline: 1
                alua_support_standby: 1
                alua_support_transitioning: 1
                alua_support_unavailable: 1
                alua_write_metadata: 0
                implicit_trans_secs: 0
                name: "default_tg_pt_gp"
                nonop_delay_msecs: 100
                preferred: 0
                tg_pt_gp_id: 0
                trans_delay_msecs: 0
            attributes:
              block_size: 512
              emulate_3pc: 1
              emulate_caw: 1
              emulate_dpo: 1
              emulate_fua_read: 1
              emulate_fua_write: 1
              emulate_model_alias: 1
              emulate_pr: 1
              emulate_rest_reord: 0
              emulate_tas: 1
              emulate_tpu: 0
              emulate_tpws: 0
              emulate_ua_intlck_ctrl: 0
              emulate_write_cache: 0
              enforce_pr_isids: 1
              force_pr_aptpl: 0
              is_nonrot: 1
              max_unmap_block_desc_count: 0
              max_unmap_lba_count: 0
              max_write_same_len: 65535
              optimal_sectors: 256
              pi_prot_format: 0
              pi_prot_type: 0
              pi_prot_verify: 0
              queue_depth: 64
              unmap_granularity: 0
              unmap_granularity_alignment: 0
              unmap_zeroes_data: 0
            dev: {{ grains['iscsidev'] }}1
            name: "sda"
            plugin: "block"
            readonly: false
            write_back: false
            wwn: "70cedf3d-800e-410a-b5f3-f73b72686581"
        targets:
          iscsi_server:
            fabric: iscsi
            tpgs:
              attributes:
                authentication: 0
                cache_dynamic_acls: 1
                default_cmdsn_depth: 16
                default_erl: 0
                demo_mode_discovery: 1
                demo_mode_write_protect: 0
                fabric_prot_type: 0
                generate_node_acls: 1
                login_keys_workaround: 1
                login_timeout: 15
                netif_timeout: 2
                prod_mode_write_protect: 0
                t10_pi: 0
                tpg_enabled_sendtargets: 1
              enable: true
              luns:
                sda:
                  alias: "d6b1e8e70a"
                  alua_tg_pt_gp_name: "default_tg_pt_gp"
                  index: 0
                  storage_object: /backstores/block/sda
                sdb:
                  alias: "6d94d0e738"
                  alua_tg_pt_gp_name: "default_tg_pt_gp"
                  index: 1
                  storage_object: /backstores/block/sdb
                sdc:
                  alias: "e9544d3a9d"
                  alua_tg_pt_gp_name: "default_tg_pt_gp"
                  index: 2
                  storage_object: /backstores/block/sdc
                sdd:
                  alias: "2ff12a7486"
                  alua_tg_pt_gp_name: "default_tg_pt_gp"
                  index: 3
                  storage_object: /backstores/block/sdd
                sde:
                  alias: "5a8095a7f0"
                  alua_tg_pt_gp_name: "default_tg_pt_gp"
                  index: 4
                  storage_object: /backstores/block/sde
              node_acls: []
              parameters:
                AuthMethod: "CHAP,None"
                DataDigest: "CRC32C,None"
                DataPDUInOrder: "Yes"
                DataSequenceInOrder: "Yes"
                DefaultTime2Retain: "20"
                DefaultTime2Wait: "2"
                ErrorRecoveryLevel: "0"
                FirstBurstLength: "65536"
                HeaderDigest: "CRC32C,None"
                IFMarkInt: "Reject"
                IFMarker: "No"
                ImmediateData: "Yes"
                InitialR2T: "Yes"
                MaxBurstLength: "262144"
                MaxConnections: "1"
                MaxOutstandingR2T: "1"
                MaxRecvDataSegmentLength: "8192"
                MaxXmitDataSegmentLength: "262144"
                OFMarkInt: "Reject"
                OFMarker: "No"
                TargetAlias: "LIO Target"
              portals:
                iscsi_server:
                  ip_address: {{ grains['iscsi_srv_ip'] }}
                  iser: false
                  offload: false
                  port: 3260
              tag: 1
            wwn: "iqn.1996-04.de.suse:01:a66aed20e2f3"