include_attribute "deploy"

node.default["opsworks_python"]["custom_type"] = "python"
node.default["opsworks_python"]["symlink_before_migrate"] = {}
node.default["opsworks_python"]["purge_before_symlink"] = []
node.default["opsworks_python"]["create_dirs_before_symlink"] = ['public', 'tmp']
node.default["opsworks_python"]["packages"] = []
node.default["opsworks_python"]["os_packages"] = []
node.default["opsworks_python"]["venv_options"] = '--no-site-packages'

include_attribute "opsworks_python::supervisor"