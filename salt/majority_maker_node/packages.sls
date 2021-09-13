# TODO: think about better place for this
remove_SAPHanaSR:
  pkg.removed:
    - pkgs:
      - SAPHanaSR
      - SAPHanaSR-doc

install_SAPHanaSR_ScaleOut:
  pkg.installed:
    - pkgs:
      - SAPHanaSR-ScaleOut
      - SAPHanaSR-ScaleOut-doc
