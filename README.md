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
factname,hive,keyname,key,type,value
CIS_CCE_25589_3,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,LimitBlankPasswordUse,dword,0
```

In the above example if the registry value of LimitBlankPasswordUse is 0 "yes" will be returned.

If the value is non 0, "no" will be returned

If key does not exist "n/a" will be returned

Note all facter facts are strings, not boolean.

