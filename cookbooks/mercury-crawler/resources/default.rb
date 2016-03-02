actions :setup, :install, :supervise

attribute :application, :kind_of => String, :name_attribute => true
attribute :deploy, :kind_of => Hash, :default => {}