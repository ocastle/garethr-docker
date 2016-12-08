require 'spec_helper'

describe 'docker::registry', :type => :define do
  let(:title) { 'localhost:5000' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

    it { should contain_exec('localhost:5000 auth') }

    context 'with ensure => present' do
      let(:params) { { 'ensure' => 'absent' } }
      it { should contain_exec('localhost:5000 auth').with_command('docker logout localhost:5000') }
    end

    context 'with ensure => present' do
      let(:params) { { 'ensure' => 'present' } }
      it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
    end

    context 'with ensure => present and username => user1' do
      let(:params) { { 'ensure' => 'present', 'username' => 'user1' } }
      it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
    end

    context 'with ensure => present and password => secret' do
      let(:params) { { 'ensure' => 'present', 'password' => 'secret' } }
      it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
    end

    context 'with ensure => present and email => user1@example.io' do
      let(:params) { { 'ensure' => 'present', 'email' => 'user1@example.io' } }
      it { should contain_exec('localhost:5000 auth').with_command('docker login localhost:5000') }
    end

    context 'with ensure => present and username => user1, and password => secret and email => user1@example.io' do
      let(:params) { { 'ensure' => 'present', 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io' } }
      it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" -e 'user1@example.io' localhost:5000").with_environment('password=secret') }
    end

    context 'with username => user1, and password => secret and email => user1@example.io' do
      let(:params) { { 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io' } }
      it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" -e 'user1@example.io' localhost:5000").with_environment('password=secret') }
    end

    context 'with username => user1, and password => secret, and email => user1@example.io and local_user => testuser' do
      let(:params) { { 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io', 'local_user' => 'testuser' } }
      it { should contain_exec('localhost:5000 auth').with_command("docker login -u 'user1' -p \"${password}\" -e 'user1@example.io' localhost:5000").with_user('testuser').with_environment('password=secret') }
    end

    context 'with an invalid ensure value' do
      let(:params) { { 'ensure' => 'not present or absent' } }
      it do
        expect {
          should contain_exec('docker logout localhost:5000')
        }.to raise_error(Puppet::Error)
      end
    end

  context 'with no explicit ensure' do
    it { should contain_augeas('Create config in /root for localhost:5000') }
    it { should contain_exec('Create /root/.docker for localhost:5000').with({
      :command => '/bin/mkdir -m 0700 -p /root/.docker',
      :creates => '/root/.docker',
    })}
    it { should contain_exec('Create /root/.docker/config.json for localhost:5000').with({
      :command => "/bin/echo '{}' > /root/.docker/config.json; /bin/chmod 0600 /root/.docker/config.json",
      :creates => '/root/.docker/config.json',
    })}
  end

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_augeas('Remove auth entry in /root for localhost:5000') }
    it { should_not contain_exec('Create /root/.docker for localhost:5000') }
    it { should_not contain_exec('Create /root/.docker/config.json for localhost:5000') }

  end

  context 'with ensure => present' do
    it { should contain_augeas('Create config in /root for localhost:5000') }
    it { should contain_exec('Create /root/.docker for localhost:5000').with({
      :command => '/bin/mkdir -m 0700 -p /root/.docker',
      :creates => '/root/.docker',
    })}
    it { should contain_exec('Create /root/.docker/config.json for localhost:5000').with({
      :command => "/bin/echo '{}' > /root/.docker/config.json; /bin/chmod 0600 /root/.docker/config.json",
      :creates => '/root/.docker/config.json',
    })}
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_augeas('Create auth entry for localhost:5000')
      }.to raise_error(Puppet::Error)
    end
  end
end
