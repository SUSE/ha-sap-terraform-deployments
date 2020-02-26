# ISCSI Server doc

ISCSI is an acronym for Internet Small Computer Systems Interface, an Internet Protocol (IP)-based storage networking standard for linking data storage facilities.

The deployment project will create the ISCSI server with terraform and provisioning with salt.

In order to use ISCSI within the deployement project you need to set this variables:

```
shared_storage_type,
iscsi_srv_ip,
iscsi_image,
```

For a full examples check out: doc/deployment-templates.md
