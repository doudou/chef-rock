buildconf_type  = 'git'
buildconf_url   = 'https://github.com/rock-core/buildconf'
username     = node['rock']['user']
release_name = node['rock']['release'] || 'stable'

ruby_path, ruby_package = node['rock']['ruby']
dev = File.expand_path(node['rock']['dev'], "/home/#{username}")

if ruby_package
    package ruby_package do
    end
end

directory dev do
    owner username
    recursive true
end

buildconf_opts = Hash[]
if !%w{master stable}.include?(release_name)
    buildconf_opts[:tag] = release_name
    flavor = 'stable'
else
    flavor = release_name
end

autoproj_workspace dev do
    buildconf type: buildconf_type,
        url: buildconf_url,
        **buildconf_opts
    ruby ruby_path
    user username
    action :bootstrap
end

template File.join(dev, 'autoproj', 'init.rb') do
    source node['rock']['init'] || "autoproj-init.rb.erb"
    owner username
    variables github_url: (node['rock']['github_url'] || 'https://github.com')
end

autoproj_config dev do
    user username
    variables 'GITHUB' => 'http,http',
        'GITORIOUS' => 'http,http',
        'ROCK_SELECTED_FLAVOR' => flavor,
        'ROCK_FLAVOR' => flavor,
        'ROCK_BRANCH' => flavor,
        'USE_OCL' => false,
        'rtt_target' => 'gnulinux',
        'rtt_corba_implementation' => 'omniorb'
end
template File.join(dev, 'autoproj', 'manifest') do
    source node['rock']['manifest'] || "autoproj-manifest.erb"
    owner username
    variables metapackages: node['rock']['metapackages']
end

