# vim: set ts=2 sw=2 ai et:
require 'facter'

module Ise
  class DomainRole
    def self.domain_role_map
      {
        0 => "Standalone_Workstation",
        1 => "Member_Workstation",
        2 => "Standalone_Server",
        3 => "Member_Server",
        4 => "Backup_Domain_Controller",
        5 => "Primary_Domain_Controller",
      }
    end

    def self.value(os = Facter.value(:kernel))
      case os
        when 'windows'; windows_value
        when 'Linux'  ; linux_value
        else          ; 'unknown'
      end
    end

    def self.linux_value
      # to-do: provide a sane answer
      'unspecified Linux role'
    end

    def self.windows_value
      require 'facter/util/wmi'
      ise_domain_role = ""
      wql = 'SELECT DomainRole from Win32_ComputerSystem'
      Facter::Util::WMI.execquery(wql).each do |host|
        ise_domain_role=domain_role_map[host.DomainRole]
        break
      end
      ise_domain_role
    end
  end
end

Facter.add(:ise_domain_role) do
  setcode { Ise::DomainRole.value }
end
