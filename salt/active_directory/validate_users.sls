# before executing other formulas/code we validate if we can use the user ha/sap
# and these have the right pre-requisites for installation
# since we this users are created by active directory externally, we need to check if they satisfy the pre-requisites

hacluster_login_ls:
  cmd.run:
    - name: su -c 'ls -l' hacluster

# hacluster user should belong to hacluster group
hacluster_group_haclient:
  cmd.run:
    - name: su -c 'groups' hacluster | grep haclient


# hana user: 
# https://help.sap.com/viewer/6b94445c94ae495c83a19646e7c3fd56/2.0.04/en-US/3c831ee47beb4499972774f4a080d1d3.html
sidadm_login_ls:
  cmd.run:
    - name: su -c 'ls -l' prdadm


sidam_has_csh_shell:
  cmd.run:
    - name: su -c 'env' prdadm | grep SHELL=/bin/csh


# The sidadm user should have a UID greater than 999.
sidadm_uid_check:
  cmd.run:
    - name: | 
        UID_SID=`su -c 'id -u' prdadm`
        if [ "$UID_SID" -le 999 ]; then
          echo "UID of sidadm user must be greather then 999";
          echo $UID_SID
          exit 1
        fi

# The primary group of the user must be sapsys. The default GID of the sapsys group is 79. 
sidadm_gid_check:
  cmd.run:
    - name: su -c 'id' prdadm | grep "gid=79(sapsys)"
