puppet-win-cis
==============
** member of the rismoney suite of puppet providers, modules and facts! **

Puppet module to manage CIS compliance for windows machines

Initial effort: It's audit time.  
Long Term Strategy: Remediation
Vision: CIS themselves engages in this repo

Create facter facts to validate systems compliance.

Approach: Create a facter fact that can read a CSV file for all CIS facts and create
facts based on that.

Status:
- [x] created factstub generator
- [x] sample keys.csv file
- [x] cisfacts rspec testing
- [ ] true windows confinement (reports n/a on non-windows)
- [ ] full cis spec added to keys.csv
- [ ] module to remediate all cis to Pass


Sample CSV
```csv
reference,domaincontroller,memberserver,reghive,key,keyname,keytype,keyvalue
cis_cce_25589_3,true,true,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,LimitBlankPasswordUse,REG_DWORD,0
cis_cce_24075_4,true,true,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,auditbaseobjects,REG_DWORD,0
```


In the above example if the registry value of LimitBlankPasswordUse is 0 "pass" will be returned.

If the value is non 0, "fail" will be returned

If key does not exist "undefined" will be returned

Note: all facter facts are strings regardless of their underlying registry key type


We welcome contributions so open a pull request in a new branch!
