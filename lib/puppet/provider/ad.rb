class Puppet::Provider::Ad < Puppet::Provider
confine :operatingsystem => :windows

    def wmi_connect
      if Puppet.features.microsoft_windows?
        begin
          require 'win32ole'
        rescue LoadError => exc
          msg = "Could not load the required win32ole gem [#{exc.message}]"
          Puppet.err msg
          error = Puppet::Error.new(msg)
          error.set_backtrace exc.backtrace
          raise error
        end
      end
      objWMIService=WIN32OLE.connect("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy}!\\\\#{@resource[:server]}\\root\\microsoftdns")
    end

    def wmi_exec_rr
     #create a connection to the service
       objWMIService=wmi_connect
       objWMIService.ExecQuery("Select * from MicrosoftDNS_ResourceRecord Where ContainerName = '#{@resource[:zone]}' AND OwnerName='#{@resource[:name]}' AND RecordData='#{@resource[:value]}'")
    end

    def wmi_exec_zone
     #create a connection to the service
       objWMIService=wmi_connect
       objWMIService.ExecQuery("Select * from MicrosoftDNS_Zone where name='#{@resource[:name]}'")
    end
        
    
    def wmi_class (rrtype)
    
     wmi_class = begin
        case rrtype
        when 'A'      ; "MicrosoftDNS_AType"
        when 'PTR'    ; "MicrosoftDNS_PTRType"
        when 'CNAME'  ; "MicrosoftDNS_CNAMEType"
        when 'AAAA'   ; "MicrosoftDNS_AAAAType"
        end
      end
    return wmi_class
    end
end