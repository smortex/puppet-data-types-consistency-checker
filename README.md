# puppet-data-types-consistency-checker

This project analyze a Puppet module
[manifests](https://puppet.com/docs/puppet/4.10/lang_visual_index.html)
(`manifests/**/*.pp`) and [epp
templates](https://puppet.com/docs/puppet/latest/lang_template_epp.html)
(`templates/**/*.epp`) and report data-types inconsistencies of variables.

It is intended to make it easy to find inconsistencies if the same variable
name is used with different data types.  This can happen if a parameter is
passed between classes, or to a template using [parameter
tags](https://puppet.com/docs/puppet/latest/lang_template_epp.html#parameter-tags).

## Usage

```
% ./puppet-data-types-consistency-checker.rb ~/Projects/puppet/modules/bacula
Inconsistencies found for $files:
  - Array                          manifests/director/fileset.pp
  - Optional[Array]                manifests/job.pp
  - Array[String]                  templates/fileset.conf.epp

Inconsistencies found for $excludes:
  - Optional[Array]                manifests/director/fileset.pp
  - Optional[Array]                manifests/job.pp
  - Array[String]                  templates/fileset.conf.epp

Inconsistencies found for $maxvoljobs:
  - Optional[Variant[String,Integer]] manifests/director/pool.pp
  - Optional[Integer]              templates/bacula-dir-pool.epp

Inconsistencies found for $maxvols:
  - Optional[Variant[String,Integer]] manifests/director/pool.pp
  - Optional[Integer]              templates/bacula-dir-pool.epp

[...]
```

Of course, if unrelated variable have the same name but different data-types,
they will be reported.  Filtering these false-positive is out of the scope of
this tool, so be ready to see this kind of output if you are concerned by this
case:

```
% ./puppet-data-types-consistency-checker.rb ~/Projects/puppet/modules/bacula
Inconsistencies found for $sched:
  - String                         manifests/jobdefs.pp
  - Optional[String]               manifests/job.pp
  - Optional[String]               templates/job.conf.epp
  - String                         templates/jobdefs.conf.epp

Inconsistencies found for $priority:
  - Integer                        manifests/jobdefs.pp
  - Optional[Integer]              manifests/job.pp
  - Optional[Integer]              templates/job.conf.epp
  - Integer                        templates/jobdefs.conf.epp

Inconsistencies found for $pool:
  - String                         manifests/jobdefs.pp
  - Optional[String]               manifests/job.pp
  - Optional[String]               templates/job.conf.epp
  - String                         templates/jobdefs.conf.epp

[...]
```

In the above example, both manifests use the same variable names, but
`manifests/job.pp` use the `templates/job.conf.epp` template and
`manifests/jobdefs.pp` use the `templates/jobdefs.conf.epp` template, so
everything is fine.
