require 'spec_helper_acceptance'

test_name 'simp-grafana-dashboards'

describe 'simp-grafana-dashboards' do

  rpm_src = File.join(fixtures_path,'dist')
  stub_rpm_src = File.join(fixtures_path,'test_module_rpms')
  grafana_dir = "/var/lib/grafana/dashboards"

  local_yum_repo = '/srv/local_yum'
  local_yum_repo_conf =<<-EOM
[local_yum]
name=Local Repos
baseurl=file://#{local_yum_repo}
enabled=1
gpgcheck=0
repo_gpgcheck=0
  EOM

  hosts.each do |host|
    context 'Setting up' do
      it 'should have git' do
        host.install_package('git')
        on(host,'git config --global user.email "root@rooty.tooty"')
        on(host,'git config --global user.name "Rootlike Overlord"')
      end
    end

    context 'Building The RPM' do
      it 'should build cleanly' do
        Bundler.with_clean_env do
          %x{rake clean}
          result = %x{rake pkg:rpm[#{host[:mock_chroot]},true]}
          raise "RPM Build Failed" unless $? == 0 && result.empty?
        end
      end
    end

    context 'Installing The RPM' do
      it 'should have the RPMs in a local repo' do
        on(host, "mkdir -p #{local_yum_repo}")

        src_rpms = []
        src_rpms += Dir.glob(File.join(rpm_src,host[:rpm_glob]))
        src_rpms += Dir.glob(File.join(stub_rpm_src,'*.rpm'))

        src_rpms.each do |rpm|
          if host[:hypervisor] == 'docker'
            %x{docker cp #{rpm} #{host[:docker_container].id}:#{local_yum_repo}}
          else
            scp_to(host, rpm, local_yum_repo)
          end
        end
      end

      it 'should create the local yum repo' do
        host.install_package('createrepo')
        host.install_package('yum-utils')
        on(host, "cd #{local_yum_repo} && createrepo .")
        create_remote_file(host, '/etc/yum.repos.d/grafana_dashboards_local.repo', local_yum_repo_conf)
      end

      it 'should install cleanly' do
        host.install_package('simp-grafana-dashboards')
        on(host, "test -d #{grafana_dir}")
        # The home dashboard will always exist
        on(host, "test -f #{grafana_dir}/home.json")
      end

      it 'should install all dashboards' do
        on(host, "test -f #{grafana_dir}/ssh.json")
        on(host, "test -f #{grafana_dir}/sudosh.json")
        on(host, "test -f #{grafana_dir}/puppet-agent.json")
      end

      it 'should uninstall cleanly' do
        host.uninstall_package('simp-grafana-dashboards')
        on(host, 'test ! -f /var/lib/grafana/dashboards/*.json')
      end
    end
  end
end
