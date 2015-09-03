# vim: set ts=2 sw=2 ai et:
require 'spec_helper'
require 'registry'

describe "on Windows" do
  before :each do
    ENV['CIS_MOCKING']="fake.csv"
    Facter.fact(:kernelrelease).stubs(:value).returns('6.3.9600')
    load File.join(File.dirname(__FILE__), '../../', 'lib', 'facter', 'cis_cce_0.rb')
  end

  describe "cis_cce_0" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('windows')
            Facter.fact(:ise_domain_role).stubs(:value).returns('Member_Server')
      #load File.join(File.dirname(__FILE__), '../../', 'lib', 'facter', 'ise_domain_role.rb')
      # note no registry gem on linux, so we stub all win32::registry methods
      Rismoney::Cis.any_instance.stubs(:reghive_table).returns({:HKEY_LOCAL_MACHINE=>'foo'})
    end

    it "if value in csv file does not match value in registry fact should be fail" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('NotFake')
      Facter.fact(:cis_cce_0).value.should == 'fail'
    end

    it "if value in csv file matches value in registry fact should be pass" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('Fake')
      Facter.fact(:cis_cce_0).value.should == 'pass'
    end

    it "if value in csv file matches value in registry fact should be undefined" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('undefined')
      Facter.fact(:cis_cce_0).value.should == 'undefined'
    end
 end
end

describe 'Rismoney::Cis' do
  before :each do
    @cisclass = Rismoney::Cis.new
    @rawcsv = [
      ["reference", "domaincontroller", "memberserver", "reghive", "key", "keyname", "keytype", "keyvalue"],
      ["cis_cce_0", "true", "true", "HKEY_LOCAL_MACHINE", "Fakekey", "FakeKeyname", "REG_SZ", "Fake"]
    ]
    @csv_ary = [
      {:reference=>"cis_cce_0",
       :domaincontroller=>"true",
       :memberserver=>"true",
       :reghive=>"HKEY_LOCAL_MACHINE",
       :key=>"Fakekey",
       :keyname=>"FakeKeyname",
       :keytype=>"REG_SZ",
       :keyvalue=>"Fake"}
    ]
    ENV['CIS_MOCKING']="fake.csv"
  end

  describe 'getfilename' do
    context 'CIS_MOCKING environment variable empty' do
      before :each do
        ENV['CIS_MOCKING']=nil
      end
      it 'getfilename should use CISWindows2012r2-1.1.0-keys.csv unless an environment variable is set' do
        @cisclass.getfilename.should == 'CISWindows2012r2-1.1.0-keys.csv'
      end
    end

    context 'CIS_MOCKING environment variable has fake.csv' do
      before :each do
        ENV['CIS_MOCKING']='fake.csv'
      end
      it 'getfilename should use fake.csv unless an environment variable is set' do
        @cisclass.getfilename.should == 'fake.csv'
      end
    end
  end

  describe 'csvprocess(csv_array)' do
    it 'csvprocess takes an array from csv and turns into a clean hash using symbols' do
      csvfile = @rawcsv
      @cisclass.csvprocess(csvfile).should == @csv_ary
    end
  end

  describe 'csvread(filename)' do
    it 'csvread should read a csv file into a value' do
      filename = 'fake.csv'
      @cisclass.csvread(filename).should == @rawcsv
    end
  end

  describe 'fact_eval(keyval,sot)' do
    context "value and source of true are ==" do
      it 'v read reads in a csv file into a value' do
        keyval='1'
        sot='1'
        @cisclass.fact_eval(keyval,sot).should == 'pass'
      end
    end
    context "value and source of true are !=" do
      it 'v read reads in a csv file into a value' do
        keyval='1'
        sot='0'
        @cisclass.fact_eval(keyval,sot).should == 'fail'
      end
    end
    context "value and source of true are ==" do
      it 'v read reads in a csv file into a value' do
        keyval='undefined'
        sot='1'
        @cisclass.fact_eval(keyval,sot).should == 'undefined'
      end
    end

  end
  describe 'windows_value item' do
    before :each do
      Rismoney::Cis.any_instance.stubs(:reghive_table).returns({:HKEY_LOCAL_MACHINE=>'foo',:HKEY_CURRENT_USER=>'bar'})
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('Fake')
    end
    it 'windows_value returns Pass/Fail or undefined for a reference number' do
      item = @csv_ary[0]
      @cisclass.windows_value(item).should == "pass"
    end
  end

   describe 'windows_value item' do
    before :each do
      Rismoney::Cis.any_instance.stubs(:reghive_table).returns({:HKEY_LOCAL_MACHINE=>'foo',:HKEY_CURRENT_USER=>'bar'})
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('NotFake')
    end
    it 'windows_value returns Pass/Fail or undefined for a reference number' do
      item = @csv_ary[0]
      @cisclass.windows_value(item).should == "fail"
    end
  end

  describe 'getKeyValue(hive, key_path, key_name)' do
    it 'is an abortion on linux testing frameworks!' do
      hive,key_path,key_name = 'busted'
      # we only test the error case since we need to stub the whole gem
      @cisclass.getKeyValue(hive, key_path, key_name).should == "undefined"
    end
  end

  describe 'isdc(whatami)' do
    it 'by default returns memberserver=>true domaincontroller=> false' do
      whatami = 'test'
      @cisclass.isdc(whatami).should == {:memberserver=>"true", :domaincontroller=>"false"}
    end

    it 'by default returns memberserver=>true domaincontroller=> false' do
      whatami = 'Primary_Domain_Controller'
      @cisclass.isdc(whatami).should == {:memberserver=>"false", :domaincontroller=>"true"}
    end

    it 'by default returns memberserver=>true domaincontroller=> false' do
      whatami = 'Backup_Domain_Controller'
      @cisclass.isdc(whatami).should == {:memberserver=>"false", :domaincontroller=>"true"}
    end
  end
end
