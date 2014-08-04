# vim: set ts=2 sw=2 ai et:
require 'spec_helper'
require 'registry'

describe "on Windows" do

  describe "cis_cce_23988_9" do
      before :each do
        Facter.fact(:kernel).stubs(:value).returns('windows')
        load File.join(File.dirname(__FILE__), '../../', 'facts', 'ise_domain_role.rb')
        load File.join(File.dirname(__FILE__), '../../', 'facts', 'cis_cce_23988_9.rb')
        # note no registry gem on linux, so we stub all win32::registry methods
        Rismoney::Cis.any_instance.stubs(:reghive_table).returns({:HKEY_LOCAL_MACHINE=>'foo',:HKEY_CURRENT_USER=>'bar'})
      end

      it "if value in csv file matches value in registry fact should be no" do
        Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('1')
        Facter.fact(:cis_cce_23988_9).value.should == 'no'
      end

      it "if value in csv file matches value in registry fact should be yes" do
        Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('0')
        Facter.fact(:cis_cce_23988_9).value.should == 'yes'
      end

  end
end
