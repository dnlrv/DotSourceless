# DotSourceless Method
An example repo on the DotSourceless (DotSource + Scriptless) design.

## Purpose
The purpose of the DotSourceless design is high portability. The ability to have classes and functions work purely from only PowerShell scripts. By using the DotSourceless snippet referenced below, all classes/functions become available within the PowerShell session. In addition, if a change is made to the repo, running the same DotSourceless snippet will get the changes to the repo.

All classes and functions will also exist as ScriptBlocks within the `$DotSourcelessScriptBlocks` variable.

Each folder of scripts in the repo needs to have a new code block added to the primary
`$DotSourceless.ps1` and `$DotSourceless_local.ps1` scripts.

Any script starting with an underscore `_` in a folder will be ignored.

## DotSourceless
```
$DotSourceless = ([ScriptBlock]::Create(((Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/dnlrv/DotSourceless/main/DotSourceless.ps1').Content))); . $DotSourceless
```

## DotSourceless (local)
If you want to run all of this locally, download all the scripts in this repo to a local folder, and run the primary script with the following:

```
. .\DotSourceless_local.ps1
```

## Current issues/limitations

- Custom class objects can't reference each other by their original TypeName, only by the PSOBject or PSCustomObject TypeName.
  - For example, if you had the `Actor` class, and also wanted to create a `Movie` class to add to the `Actor` class to list what movies an actor/actress has been in, you'd need to refer to it as the following:

```
class Actor
{
	[System.String]$Name
	[PSCustomObject[]]$Movies

	Actor () {}
}
```
Note in the above example, I'm referring to the Movies property by `[PSCustomObject[]]$Movies` TypeName rather than the `[Movie[]]$Movies` TypeName.

Failing to do this will result in a `Cannot find type [Movie]` error when you dotsource all the scripts. I don't know how to address this while still keeping with this project's current design.