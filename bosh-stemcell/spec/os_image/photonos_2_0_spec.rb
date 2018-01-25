require 'spec_helper'

describe 'Photonos 2 OS image', os_image: true do

  context 'gdisk' do
        describe file('/sbin/gdisk') do
      it { should be_file }
    end
  end

  context 'installed by base_photonos' do
        describe file('/etc/photon-release') do
      it { should be_file }
    end

    describe file('/etc/locale.conf') do
      it { should be_file }
      its(:content) { should match 'en_US.UTF-8' }
    end
  end

  context 'ensure sendmail is removed (stig: V-38671)' do
        describe file('/usr/sbin/sendmail') do
      it { should_not be_file }
    end
  end
end


