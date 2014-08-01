puppet-win-cis
==============

Puppet module to manage CIS compliance for windows machines

Initial effort: It's audit time.  Remediation comes later!

Create facter facts to validate systems compliance.
Approach: Dynamically create facter facts from an erb template to avoid as much manual effort.

Status:
Draft of Registry facter facts generator is done.  At this point simply modify the registry
keys in the keys.csv and run the factgen.  This will spit out facter facts that do the following:

```csv
factname,hive,keyname,key,type,value
CIS_CCE_25589_3,HKEY_LOCAL_MACHINE,System\CurrentControlSet\Control\Lsa,LimitBlankPasswordUse,dword,0
```

In the above example if the registry value of LimitBlankPasswordUse is 0 "yes" will be returned.

If the value is non 0, "no" will be returned

If key does not exist "n/a" will be returned

Note all facter facts are strings, not boolean.

