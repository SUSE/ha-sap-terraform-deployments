
You must create a `public_cloud_images` directory populated with the images you want to upload and edit `sles_os_image_file` and `sles4sap_os_image_file` in the [variables.tf](variables.tf) files with the filenames of the images.  Or you can run:

`terraform apply -var "sles_os_image_file=SLES12-SP4-GCE-BYOS.x86_64-0.9.3-Build1.19.tar.gz" -var "sles4sap_os_image_file=SLES12-SP4-SAP-GCE-BYOS.x86_64-0.9.4-Build1.26.tar.gz"`

Notes:
  - The `public_cloud_images` name is defined in the variable `images_path`.
  - By default, the images are uploaded to the bucket `sle-image-store` (the name is defined in the variable `images_path_bucket`). You must make sure that this bucket name is globally unique as defined in the [official documentation](https://cloud.google.com/storage/docs/naming#requirements)