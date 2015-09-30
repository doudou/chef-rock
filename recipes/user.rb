username = node['rock']['user']

user username do
    manage_home true
    home "/home/#{username}"
end

file "/etc/sudoers.d/#{username}" do
    content "#{username} ALL=(ALL) NOPASSWD:ALL"
    owner "root"
    group 'root'
    mode '0440'
end

