# DotSourceless Method
An example repo on the DotSourceless (DotSource + Scriptless) design.

## Purpose
The purpose of the DotSourceless design is high portability. The ability to have classes and functions work purely from only PowerShell scripts. By using the DotSourceless snippet referenced below, all classes/functions become available within the PowerShell session. In addition, if a change is made to the repo, running the same DotSourceless snippet will get the changes to the repo.

All classes and functions will also exist as ScriptBlocks within the `$DotSourcelessScriptBlocks` variable.

New scripts can be added to the Classes or Functions folders, however any script starting with an underscore (_) will be ignored.

## DotSourceless
```
$DotSourceless = ([ScriptBlock]::Create(((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/dnlrv/DotSourceless/main/DotSourceless.ps1').Content))); . $DotSourceless
```

## DotSourceless (local)
If you want to run all of this locally, download all the scripts in this repo to a local folder, and run the primary script with the following:

```
. .\DotSourceless_local.ps1
```