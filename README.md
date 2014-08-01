puppet-win-cis
==============

Puppet module to manage CIS compliance for windows machines

Initial effort: It's audit time.  Remediation comes later!

Create facter facts to validate systems compliance.

Approach: Create a facter fact that can read a CSV file for all CIS facts and create
facts based on that.

Status:
Scrapped factgen approach.  One fact to rule them all!

```csv
reference,domaincontroller,memberserver,reghive,key,keyname,keytype,keyvalue
cis_cce_25589_3,true,true,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,LimitBlankPasswordUse,REG_DWORD,0
cis_cce_24075_4,true,true,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,auditbaseobjects,REG_DWORD,0
```

note to self: need to update to Pass/Fail instead of yes/no

In the above example if the registry value of LimitBlankPasswordUse is 0 "yes" will be returned.

If the value is non 0, "no" will be returned

If key does not exist "n/a" will be returned

Note all facter facts are strings, not boolean.

