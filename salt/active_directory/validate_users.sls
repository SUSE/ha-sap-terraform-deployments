# before executing other formulas/code we validate if we can use the user ha/sap
# and these have the right pre-requisites for installation

hacluster_login_ls:
  cmd.run:
    - name: su -c 'ls -l' hacluster

hacluster_login_ls:
  cmd.run:
    - name: su -c 'ls -l' hacluster


# hana user: 
# https://help.sap.com/viewer/6b94445c94ae495c83a19646e7c3fd56/2.0.04/en-US/3c831ee47beb4499972774f4a080d1d3.html
sidadm_login_ls:
  cmd.run:
    - name: su - c 'ls -l' prdadm
