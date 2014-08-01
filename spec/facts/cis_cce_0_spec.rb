# vim: set ts=2 sw=2 ai et:
require 'spec_helper'
require 'registry'
#require File.join(File.dirname(__FILE__), '../../', 'facts', 'cis_cce_23988_9.rb')

describe "on Windows" do
  before :each do
    ENV['CIS_MOCKING']="fake.csv"
    load File.join(File.dirname(__FILE__), '../../', 'facts', 'cis_cce_0.rb')
  end

  describe "cis_cce_0" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('windows')
      load File.join(File.dirname(__FILE__), '../../', 'facts', 'ise_domain_role.rb')
      # note no registry gem on linux, so we stub all win32::registry methods
      Rismoney::Cis.any_instance.stubs(:reghive_table).returns({:HKEY_LOCAL_MACHINE=>'foo',:HKEY_CURRENT_USER=>'bar'})
    end

    it "if value in csv file does not match value in registry fact should be no" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('NotFake')
      Facter.fact(:cis_cce_0).value.should == 'fail'
    end

    it "if value in csv file matches value in registry fact should be yes" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('Fake')
      Facter.fact(:cis_cce_0).value.should == 'pass'
    end

    it "if value in csv file matches value in registry fact should be yes" do
      Rismoney::Cis.any_instance.stubs(:getKeyValue).returns('undefined')
      Facter.fact(:cis_cce_0).value.should == 'undefined'
    end

  end
end

describe 'other OS' do
  before :each do
    ENV['CIS_MOCKING']="fake.csv"
    load File.join(File.dirname(__FILE__), '../../', 'facts', 'cis_cce_0.rb')
  end

  context "when kernel => 'Linux'" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('Linux')
    end
    it "Linux fact should return n/a" do
      Facter.fact(:cis_cce_0).value.should == 'n/a'
    end
  end

  context "when kernel => 'booga'" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('booga')
    end
    it "Linux fact should return n/a" do
      Facter.fact(:cis_cce_0).value.should == 'unknown'
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
      it 'getfilename should use keys.csv unless an environment variable is set' do
        @cisclass.getfilename.should == 'keys.csv'
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
    it 'csv read reads in a csv file into a value' do
      filename = 'fake.csv'
      @cisclass.csvread(filename).should == @rawcsv
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
