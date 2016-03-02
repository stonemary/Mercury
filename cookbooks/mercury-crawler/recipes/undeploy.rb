node["deploy"].each do |application, deploy|

  if deploy["application_type"] != "other" || deploy["custom_type"] != 'python'
    Chef::Log.debug("Skipping deploy_python::undeploy for application #{application} as it is not a python app")
    next
  end

  virtualenv application + '-venv' do
    action :delete
  end

  to = deploy[:deploy_to]
  directory to do
    recursive true
    action :delete
    only_if ::File.exists?(to)
  end

  supervisor_service application do
    action :stop
  end
end