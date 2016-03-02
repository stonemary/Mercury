default["opsworks_python"]["supervisor"] = {
	:action =>  [:enable, :start],
	:autostart => true,
	:autorestart => true,
	:redirect_stderr => true,
	:stdout_logfile => "/var/log/supervisor/%(program_name)s.log",
	:script => "application.py"
}

node["deploy"].each do |application, deploy|
	default["deploy"][application]["opsworks_python"]["supervisor"] = default["opsworks_python"]["supervisor"]
end