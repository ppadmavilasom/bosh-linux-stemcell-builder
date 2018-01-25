require 'spec_helper'

describe 'Photonos 2 stemcell', stemcell_image: true do

  context 'installed by system_parameters' do
    describe file('/etc/photon-release') do
      it { should be_file }
    end
  end
end
