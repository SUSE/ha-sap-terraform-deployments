# Saltstack for SHAP.

# Guidelines:

* When install pkg consider to add retry ( in order to increase reability).
  The standard pattern  in codebase is following:

  ```
  nfs-client:
    pkg.installed
    - retry:
       attempts: 3
       interval: 15
  ```
