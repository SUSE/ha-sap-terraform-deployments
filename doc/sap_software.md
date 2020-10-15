# Preparing the SAP software

In order to use the project some preliminary steps are required. One of them is to prepare the SAP installation software. This depends on the desired landscape.
The software can be downloaded from https://launchpad.support.sap.com/#/softwarecenter

Find here a guideline to know how to configure your storage.

## Requirements

Here are the things that the user must implement/have before using the project. **They are not executed by the project**:

- Download and structure the SAP installation software in the correct storage option for each provider.
- Check the compatibility between the SAP software and tools (HANA database version with S/4HANA version, and SWPM version with desired Netweaver/S4HANA version, for example).
- Check if the files are properly uploaded or structured. If they are not, the project execution fails, sometimes being really difficult to find the root cause.

## SAP HANA

To install the SAP HANA database, the HANA installation software must be available. This software is available in different formats.

1. HANA platform in `.zip` or multipart `.rar` archive format. HANA platform edition contains all HANA components like HANA Database, Client, Studio, XS Engine etc. The multipart `rar` archive consists of a group of `.exe` and `.rar` files. To use an archive for the installation, it can be uploaded as it is (uploading all the files to the storage) or after extracting the contents with any compression tools (`unrar` for example. Find more information about how to extract in: https://launchpad.support.sap.com/#/notes/0001791258). The extracted HANA platform can be recognized checking the `LABEL.ASC` file in the main folder. It should look like (it can have a different version): `HDB:HANA:2.0:LINUX_X86_64:SAP HANA PLATFORM EDITION 2.0::BD51054084`

  Example: `51053381_part1.exe`, `51053381_part2.rar`, `51053381_part3.rar` and `51053381_part4.rar`

2. HANA database in `.SAR` format. This archive format consist of only the HANA Database Server component. It contains a particular Patch level or revision of only the database component of HANA platform. To extract this option, the SAP `SAPCAR` utility is mandatory, which must be downloaded from the SAP download center.

  Example: `IMDB_SERVER_2_00_037_05.SAR` and `SAPCAR_1311_80000935.EXE`

## SAP Netweaver or S/4HANA

SAP Netweaver or S/4HANA are installed using the SAP Software Provisioning Manager (SWPM). The SWPM tool has different versions (1.0 and 2.0 major versions) and each version of this tool supports installation of only compatible Netweaver or S/4 HANA versions. **Note:** It is important to check and use the right versions to avoid issues during SAP installation. To install NW750 and S4HANA 1709 versions, SWPM version 1.0 is needed. Beyond S4HANA 1809 SWPM version 2.0 is needed.

### SWPM version 1.0

To install Netweaver versions based on SWPM version 1, the next files are required. **They can be uploaded without any predefined structure, as long as all of them are available during the installation.**

1. `SWPM` archive. This usually comes compressed as a `.SAR` file and requires the SAP `SAPCAR` utility to get extracted. It contains a `LABEL.ASC` such as `IND:SLTOOLSET:1.0:SWPM:*:LINUX_X86_64:*`.

  Example: `SWPM10SP28_5-20009701.SAR`

2. Netweaver export files. Usually, it consists of a group of `.exe` and `.rar` files. The extracted folder has a `LABEL.ASC` such as `SAP:S4HANA:1709:DVD_EXPORT:S4HANA OP 102 Installation Export DVD 1/1:BD51052190` or `SAP:NETWEAVER:750:DVD_EXPORT:SAP NetWeaver 750 Installation Export DVD 1/1:D51050829_2`. This folder can be uploaded to the storage uploading all the files or the already extracted version.

3. HANA client. This can be either the HANA platform used in the HANA installation or the HANA client. The HANA client comes usually as `IMDB_CLIENT.SAR`.

  Example: `IMDB_CLIENT20_005_111-80002082.SAR`

4. SAP exe folder or download basket. The download basket must be complemented with the next archives. All of this components must be uploaded in the same folder.
  1. `SAPEXE.SAR`. Example: `SAPEXE_400-80000699.SAR`
  2. `SAPEXEDB.SAR`. Example: `SAPEXEDB_400-80000698.SAR`
  3. `igsexe.sar`. Example: `igsexe_1-80001746.sar`
  4. `igshelper.sar`. Example: `igshelper_4-10010245.sar`
  5. `SAPHOSTAGENT.SAR`. Example: `SAPHOSTAGENT24_24-20009394.SAR`

Below would be an example on how to configure the `terraform.tfvas` file based on above SAP components (the paths are relative paths from the used storage name).

```
netweaver_swpm_folder = "SWPM10SP28" # Already uncompressed SWPM.SAR archive
netweaver_sapexe_folder = "download_basket" # Folder containing all the files from point 4.
netweaver_additional_dvds = ["51050829", "SAP_HANA_CLIENT"] # Already uncompressed export and HANA client
```

Or

```
netweaver_swpm_folder = "SWPM10SP28_5-20009701.SAR" # Already uncompressed SWPM.SAR archive
netweaver_sapcar_exe = "SAPCAR.EXE"
netweaver_sapexe_folder = "download_basket" # Folder containing all the files from point 4.
netweaver_additional_dvds = ["51050829_part1.exe", "IMDB_CLIENT20_005_111-80002082.SAR"] # Compressed export and HANA client
```

### SWPM version 2.0

To install S4HANA 1809 and beyond based on SWPM version 2, the next files are required. **This version requires to have all of the files in the same folder (except the SWPM archive, that can be stored elsewhere), so create a folder in the storage (`download_basket` for example) and upload all of the required files there.**

1. `SWPM` archive. This usually comes compressed as a `.SAR` file, so the `SAPCAR` utility is required too. It will contain a `LABEL.ASC` such as `IND:SLTOOLSET:2.0:SWPM:*:LINUX_X86_64:*`.

  Example: `SWPM20SP05_5-80003424.SAR`

2. S4HANA export files. Usually, it consist on a group of `.zip` files. They have to be uploaded as they are, without uncompressing them.

  Example: `S4CORE104_INST_EXPORT_1.zip`, `S4CORE104_INST_EXPORT_2.zip`, etc

3. HANA client. This version only accepts the `SAR` option.

  Example: `IMDB_CLIENT20_005_111-80002082.SAR`

4. SAP exe folder or download basket. The download basket must be complemented with the next archives. All of this components must be uploaded in the same folder.
  1. `SAPEXE.SAR`. Example: `SAPEXE_400-80000699.SAR`
  2. `SAPEXEDB.SAR`. Example: `SAPEXEDB_400-80000698.SAR`
  3. `igsexe.sar`. Example: `igsexe_1-80001746.sar`
  4. `igshelper.sar`. Example: `igshelper_4-10010245.sar`
  5. `SAPHOSTAGENT.SAR`. Example: `SAPHOSTAGENT24_24-20009394.SAR`

This would be an example on how to configure the `terraform.tfvas` file for this option (the paths are relative paths from the used storage name).

```
netweaver_swpm_folder = "SWPM20SP05" # Already uncompressed SWPM.SAR archive
netweaver_sapexe_folder = "download_basket" # Folder containing all the files from point 2, 3 and 4.
```

Or

```
netweaver_swpm_folder = "SWPM10SP28_5-20009701.SAR" # Already uncompressed SWPM.SAR archive
netweaver_sapcar_exe = "SAPCAR.EXE"
netweaver_sapexe_folder = "download_basket" # Folder containing all the files from point 2, 3 and 4.
```

Some references:
- https://help.sap.com/viewer/adbfaa9e0ed64fd4a8f420cb2b26a4e1/CURRENT_VERSION_SWPM20/en-US
- https://help.sap.com/viewer/1cd327bf4d094211af157e69ff68db1b/CURRENT_VERSION/en-US


## Storage options

After downloading the described options, the files must be stored in the corresponding storage. Create a folder with a meaningful name (`sap_download_basket` for example), and upload there all the files. It's recommended to create specific subfolders for the different concepts (`hana`, `netweaver` or `s4hana`) and upload the specific files, this reduces the amount of downloaded data. Otherwise, the project downloads all the files, which are quite large in size.

- AWS - S3 bucket
- Azure - Storage account
- GCP - GCP storage
- Libvirt - NFS share
