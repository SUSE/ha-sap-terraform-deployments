# SAP Product Password Rules

  Every SAP product comes with its own set of password rules. Terraform will check the passwords `hana_master_password`
  and `netweaver_master_password` configured in `terraform.tfvars` for default rules. If another ruleset is favored,
  it is advisable to use passwords following the default rules, then deploying the system and change to the new ruleset
  from  inside the system afterwards.

  The password rule checks can be found in `generic_modules/common_variables/*.tf`.


## SAP HANA

  The password for SAP HANA supports password lengths between 8 up to 64 characters.
  It can be composed of lowercase letters (`a-z`), uppercase letters (`A-Z`) and numerical
  digits (`0-9`). All other characters are considered as special character.
  The default configuration requires passwords to contain at least one uppercase letter,
  at least one number, and at least one lowercase letter, with special characters being optional.

  For further configuration options of the password rules see:

  - https://help.sap.com/docs/SAP_HANA_PLATFORM/009e68bc5f3c440cb31823a3ec4bb95b/974e9cb991704d05a256241a7b821971.html?locale=en-US&version=2.0.05

  - https://help.sap.com/docs/SAP_HANA_ONE/102d9916bf77407ea3942fef93a47da8/61662e3032ad4f8dbdb5063a21a7d706.html?locale=en-US


## SAP NetWeaver/SAP S/4HANA

  The password for SAP NetWeaver supports password lengths between 6 and 40 characters.
  The password can only consist of digits, letters, and the following (ASCII) special characters: `!"@ $%&/()=?'*+~#-_.,;:{[]}<>`, and space and the grave accent.
  The password can consist of any characters including national special characters (such as `ä`, `ç`, `ß` from ISO Latin-1, 8859-1).
  However, all characters that aren’t contained in the set above are mapped to the same special character, and the system therefore doesn’t differentiate between them.

  For further configuration options of the password rules see:

  - https://help.sap.com/docs/SAP_NETWEAVER_750/c6e6d078ab99452db94ed7b3b7bbcccf/4ac3f18f8c352470e10000000a42189c.html?locale=en-US
