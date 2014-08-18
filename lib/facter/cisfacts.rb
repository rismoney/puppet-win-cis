require 'csv'
require 'facter'

module Rismoney
  class Cis
    def value(cis_item,os=Facter.value(:kernel))
      case os
        when 'windows' then windows_value cis_item
        when 'Linux' then 'n/a'
        else 'unknown'
      end
    end

    def getfilename
      if ENV.key?('CIS_MOCKING')
        return ENV['CIS_MOCKING'].to_s
      else
        return 'keys.csv'
      end
    end

    def gettailorfilename
      if ENV.key?('CIS_MOCKING')
        return ENV['CIS_MOCKING_TAILOR'].to_s
      else
        return 'tailor.csv'
      end
    end


    def csvprocess(csv_array)
      result = []
      return result if csv_array.nil? || csv_array.empty?
      headerA = csv_array.shift             # remove first array with headers from array returned by CSV
      headerA.map!{|x| x.downcase.to_sym }  # make symbols out of the CSV headers
      csv_array.each do |row|               #    convert each data row into a hash, given the CSV headers
      result << Hash[ headerA.zip(row) ] 
      end
      # format: reference,domaincontroller,memberserver,reghive,key,keyname,keytype,keyvalue
      return result
    end

    def csvread(filename)
      input_file_path = File.expand_path(filename,File.dirname(__FILE__))
      config = CSV.read(input_file_path)
      return config
    end

    def reghive_table
      {
        :HKEY_LOCAL_MACHINE  => Win32::Registry::HKEY_LOCAL_MACHINE,
        :HKEY_CURRENT_USER   => Win32::Registry::HKEY_CURRENT_USER,
      }
    end
    
    def isdc(whatami)
      case whatami
      when "Backup_Domain_Controller", "Primary_Domain_Controller"
        {
          :memberserver  => "false",
          :domaincontroller => "true",
        }
      else
        {
          :memberserver  => "true",
          :domaincontroller => "false",
        }
      end
    end

    def getKeyValue(hive, key_path, key_name) 
      if RUBY_PLATFORM =~ /mswin|mingw32|windows/
        require 'win32/registry'
      end
      begin 
        reg_obj=hive.open(key_path, Win32::Registry::KEY_READ) 
        reg_typ, reg_val = reg_obj.read(key_name) 
      #need to investigate error handling when rspec'ing
      #rescue Win32::Registry::Error 
      #  return "undefined"
      rescue 
        return 'undefined'
      end
        case reg_typ
          # treat everything as strings since thats what facter uses on puppet 2.x
          when 3 then returnval = reg_val.unpack('H*').to_s # REG_BINARY
          # else handles REG_DWORD and REG_SZ (reg_typ=4), and REG_SZ (reg_type=1) respectively
          else returnval = reg_val.to_s
        end
      return returnval
    end 

    def fact_eval(keyval,sot)
      case keyval
        when "undefined" then fact_name = "undefined"
        when sot then fact_name = "pass"
        else fact_name = "fail"
      end
      fact_name
    end

    def windows_value item
      reg_keytype = item[:reghive].to_sym
      method_sym = reghive_table[reg_keytype]
      hive = method_sym
      keyval = getKeyValue(hive,item[:key],item[:keyname])
      fact_eval keyval,item[:keyvalue]
      rescue LoadError
        continue 
      rescue 
        fact_name='uandefined'
    end
  end
end

cis=Rismoney::Cis.new
filename = cis.getfilename
csv = cis.csvread filename
csv_data = cis.csvprocess(csv)
tailor_filename = cis.gettailorfilename
tailor = cis.csvread tailor_filename
tailor_data = cis.csvprocess(tailor)

domainrole=cis.isdc Facter.value(:ise_domainrole)
  csv_data.each do |item|
    if domainrole[:domaincontroller] == item[:domaincontroller].to_s or domainrole[:memberserver]  == item[:memberserver].to_s
      Facter.add(item[:reference]) do
      setcode { cis.value item}
    end
  end
end
