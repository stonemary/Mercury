action :setup do
	setup(new_resource.name, new_resource.deploy)
  new_resource.updated_by_last_action(false)
end

action :install do
	install(new_resource.name, new_resource.deploy)
  new_resource.updated_by_last_action(false)
end

action :supervise do
  supervise(new_resource.name, new_resource.deploy)
  new_resource.updated_by_last_action(false)
end


def setup(application, deploy)
  Chef::Log.debug("*****************************************")
  Chef::Log.debug("Running #{recipe_name} for #{application}")
  Chef::Log.debug("*****************************************")

  os_packages = deploy["os_packages"] ? deploy["os_packages"] : node["opsworks_python"]["os_packages"]
  # Install os dependencies
    os_packages.each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end

  # We need to establish a value for the original pip/venv location as
  # a baseline so we don't find the older ones later, we assume ubuntu
  # here, because we are lazy and this is for OpsWorks
  node.normal['python']['pip_location'] = "/usr/local/bin/pip"
  node.normal['python']['virtualenv_location'] = "/usr/local/bin/virtualenv"
  # We also need to override the prior override
  node.override['python']['pip_location'] = "/usr/local/bin/pip"
  node.override['python']['virtualenv_location'] = "/usr/local/bin/virtualenv"

  py_version = deploy["python_major_version"]
  use_custom_py = py_version && py_version != "2.7"
  pip_ver_map = {
    "2.4" => "1.1",
    "2.5" => "1.3.1",
    "2.6" => "1.5.4"
  }
  virtualenv_ver_map = {
    "2.4" => "1.7.2",
    "2.5" => "1.9.1",
    "2.6" => "1.11.4"
  }
  if use_custom_py
    # We need to install an older python
    py_command = "python#{py_version}"
    apt_repository 'deadsnakes' do
      uri 'http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu'
      distribution node['lsb'] && node['lsb']['codename'] || 'precise'
      components ['main']
      keyserver "keyserver.ubuntu.com"
      key "DB82666C"
      action :add
    end
    package "#{py_command}-dev"
    package "#{py_command}-setuptools" do
      action :install
      ignore_failure true  # This one doesn't always exist
    end
    package "#{py_command}-distribute-deadsnakes" do
      action :install
      ignore_failure true  # This one doesn't always exist
    end
    # only set the python binary for this chef run, once the venv is
    # established we don't want to keep this around
    node.override['python']['binary'] = "/usr/bin/#{py_command}"
    # We use easy install to install pip, because get-pip.py seems to
    # fail on some python versions
    pip = "pip"
    pip_ver = pip_ver_map[py_version]
    pip << "==#{pip_ver}" if pip_ver
    venv = "virtualenv"
    venv_ver = virtualenv_ver_map[py_version]
    venv << "==#{venv_ver}" if venv_ver
    execute "/usr/bin/easy_install-#{py_version} #{pip} #{venv}"
    node.override['python']['pip_location'] = "/usr/bin/pip#{py_version}"
    node.override['python']['virtualenv_location'] = "/usr/bin/virtualenv-#{py_version}"
  end

  python_pip "setuptools" do
    version 3.3
    action :upgrade
    only_if do !use_custom_py end
  end

  # Set deployment user home dir, OpsWorks normally does this
  if !deploy[:home]
    node.default[deploy][application][:home] = ::File.join('/home/', deploy["user"])
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  directory "#{deploy[:deploy_to]}/shared" do
    group deploy[:group]
    owner deploy[:user]
    mode 0770
    action :create
    recursive true
  end
end

def install(application, deploy)

  venv_path = ::File.join(deploy[:deploy_to], 'shared', 'env')
  node.normal["deploy"][application]["venv"] = venv_path
  python_virtualenv application + '-venv' do
    path venv_path
    owner deploy[:user]
    group deploy[:group]
    action :create
  end

  packages = deploy["packages"] ? deploy["packages"] : node["opsworks_python"]["packages"]

  # Install pip dependencies
  packages.each do |name, ver|
    python_pip name do
      version ver if ver && ver.length > 0
      virtualenv venv_path
      user deploy[:user]
      group deploy[:group]
      action :install
    end
  end

  requirements_file = ::File.join(deploy[:deploy_to], "current", "requirements.txt")
  python_pip requirements_file do
    action :install
    options "-r"
    virtualenv venv_path
    user deploy[:user]
    group deploy[:group]
    only_if {::File.exists?(requirements_file)}
  end

  # Create environment file
  template ::File.join(deploy[:deploy_to], "shared","app.env") do
    source "app.env.erb"
    mode 0770
    owner deploy[:user]
    group deploy[:group]
    variables(
      :environment => OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
    )
    only_if {::File.exists?("#{deploy[:deploy_to]}/shared")}
  end
end

def supervise(application, deploy)
  options = deploy["opsworks_python"]["supervisor"]
  venv_path = ::File.join(deploy[:deploy_to], 'shared', 'env')
  env = OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
  env["PATH"] = venv_path
  script_path = ::File.join(deploy[:deploy_to], 'current', options["script"])
  python_path = ::File.join(venv_path, "bin", "python")

  command = "#{python_path} #{script_path}"
  if options[:command]
    command = options[:command]
    if options.has_key?("command_in_env")
      command = ::File.join(venv_path, command)
    end
  end

  Chef::Log.info("supervisor command for application #{application} is #{command}")
  supervisor_service application do
    command command
    environment env
    process_name application
    numprocs options[:numprocs]
    numprocs_start options[:numprocs_start]
    priority options[:priority]
    autostart options[:autostart]
    autorestart options[:autorestart]
    startsecs options[:startsecs]
    startretries options[:startretries]
    exitcodes options[:exitcodes]
    stopsignal options[:stopsignal]
    stopwaitsecs options[:stopwaitsecs]
    user options[:user]
    redirect_stderr options[:redirect_stderr]
    stdout_logfile options[:stdout_logfile]
    stdout_logfile_maxbytes options[:stdout_logfile_maxbytes]
    stdout_logfile_backups options[:stdout_logfile_backups]
    stdout_capture_maxbytes options[:stdout_capture_maxbytes]
    stdout_events_enabled options[:stdout_events_enabled]
    stderr_logfile options[:stderr_logfile]
    stderr_logfile_maxbytes options[:stderr_logfile_maxbytes]
    stderr_logfile_backups options[:stderr_logfile_backups]
    stderr_capture_maxbytes options[:stderr_capture_maxbytes]
    stderr_events_enabled options[:stderr_events_enabled]
    umask options[:umask]
    serverurl options[:serverurl]
  end
end