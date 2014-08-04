module Win32
  class Registry
    module Constants
      KEY_READ = 0x00020000 | 0x0001 | 0x0008 | 0x0010
      REG_OPTION_RESERVED = 0x0000
    end

    include Constants

    def read_i(name)
      return "testing"
    end

    def read_bin(name)
    end

    def read_s(name)
    end

    class HKEY_LOCAL_MACHINE
      def self.open(hkey, subkey, desired = KEY_READ, opt = REG_OPTION_RESERVED)
      end
    end

  end
end
