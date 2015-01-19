## Installation

1. Copy the contents of masterfiles into your masterfiles or equivalent repository.
1. Include all EFL .cf files in your inputs list in the common control body. Example:

```
bundle common efl_lib
{
   vars:
      cfengine_3_6::
         'lib_dir' string => 'lib/3.6/EFL';
         'inputs'   slist => {
            '${lib_dir}/efl_common.cf',
            '${lib_dir}/efl_update.cf',
            '${lib_dir}/evolve_freelib.cf'
         };
}

body common control
{
   inputs => {
      ....
      '@{efl_lib.inputs}',
      ....
   };
}
```
Next, build your data files to feed the bundles. Typically store the data files in masterfiles/efl_data.

## Building data files

Here's a trivial example to get you started.  First create data file to define class.
```
vim masterfiles/efl_data/classes/efl_classmatch.json
[
   {
      "class_to_set" : "my_dmz_hosts",
      "regex"        : "ipv4_10_0_[2,3,4]_\d+",
      "promisee"     : "dmz security"
   }
]

Then a command promise.
vim masterfiles/efl_data/bundle_params/efl_command.json
[
   {
      "class" : "my_dmz_hosts",
      "command" : "/usr/local/sbin/encrypt_backup.sh",
      "useshell" : "noshell",
      "module" : "no",
      "ifelapsed" : "1440",
      "promisee" : "dmz security"
   }
]

Call both via the efl_main bundle.
vim mastefiles/efl_data/bundle_params/efl_main.json
[
   {
      "class" : "any"
      "promiser" : "set classes",
      "bundle" : "efl_class_classmatch",
      "ifelapsed" : "1",
      "parameter" : "${sys.inputdir}/efl_data/bundle_params/efl_classmatch.json",
      "promisee" : "cfengine policy"
   },
   {
      "class" : "any",
      "promiser" : "running commands",
      "bundle" : "efl_command",
      "ifelapsed" : "1",
      "parameter" : "${sys.inputdir}/efl_data/bundle_params/efl_command.json",
      "promisee" : "cfengine policy"
   }
]
```

Elsewhere in your policy call the bundle efl_main with the parameter of the path to efl_main.json. Examples:

```
body common control
{
   bundlesequence => { .... "efl_main( '${sys.inputdir}/efl_data/bundle_params/efl_main.json' )", ... };
   ...
}

OR

bundle again mymain
{
   methods:
      "EFL" usebundle => efl_main( "${sys.inputdir}/efl_data/bundle_params/efl_main.json" );
      ...
}
```
