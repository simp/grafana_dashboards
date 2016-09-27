require 'spec_helper_acceptance'

test_name 'simp-adapter'

describe 'simp-adapter' do

  rpm_src = File.join(fixtures_path,'dist')
  stub_rpm_src = File.join(fixtures_path,'test_module_rpms')

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
          %x{rake pkg:rpm[#{host[:mock_chroot]},true]}
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
        create_remote_file(host, '/etc/yum.repos.d/beaker_local.repo', local_yum_repo_conf)
      end

      it 'should install cleanly' do
        host.install_package('pupmod-simp-beakertest')
        on(host, 'test -d /usr/share/simp/modules/beakertest')
      end

      it 'should copy the module data into the appropriate location' do
        @install_target = host.puppet['codedir']
        if !@install_target || install_target.empty?
          @install_target = host.puppet['confdir']
        end

        on(host, "test -d #{@install_target}/environments/simp/modules/beakertest")
        on(host, "diff --no-dereference -aqr /usr/share/simp/modules/beakertest #{@install_target}/environments/simp/modules/beakertest")
      end

      it 'should uninstall cleanly' do
        host.uninstall_package('pupmod-simp-beakertest')
        on(host, 'test ! -d /usr/share/simp/modules/beakertest')
        on(host, "test ! -d #{@install_target}/environments/simp/modules/beakertest")
      end
    end

    context "Installing with an already managed target" do
      it 'should have a git managed beakertest module' do
        host.mkdir_p("#{@install_target}/environments/simp/modules/beakertest")
        on(host, "cd #{@install_target}/environments/simp/modules/beakertest && git init . && git add . && git commit -a -m woo")
      end

      it 'should install cleanly' do
        host.install_package('pupmod-simp-beakertest')
        on(host, 'test -d /usr/share/simp/modules/beakertest')
      end

      it 'should NOT copy the module data into the $codedir' do
        on(host, "test -d #{@install_target}/environments/simp/modules/beakertest")
        on(
          host,
          "diff --no-dereference -aqr /usr/share/simp/modules/beakertest #{@install_target}/environments/simp/modules/beakertest",
          :acceptable_exit_codes => [1]
        )
      end

      it 'should uninstall cleanly' do
        host.uninstall_package('pupmod-simp-beakertest')
        on(host, 'test ! -d /usr/share/simp/modules/beakertest')
      end

      it 'should NOT remove the functional module from the system' do
        on(host, "test -d #{@install_target}/environments/simp/modules/beakertest")
      end
    end
  end
end
