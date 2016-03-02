name             'mercury-crawler'
maintainer       'stonemary'
maintainer_email 'stonary.henary@gmail.com'
license          'MIT'
description      'Installs/Configures mercury-crawler'
long_description 'Installs/Configures mercury-crawler'
version          '0.1.0'

depends "deploy"
depends "scm_helper"
depends "opsworks_initial_setup"

# Non Opsworks cookbook
depends "python"
depends "supervisor"

recipe "opsworks_python::deploy", "Install and setup a python application in a virtualenv"
recipe "opsworks_python::r3-mount-patch", "Patch to mount /mnt filesystems for r3 instances"

supports "amazon"