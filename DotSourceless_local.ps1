#######################################
#region ### MAIN ######################
#######################################

# ArrayList to put all our scripts into
$DotSourcelessScripts = New-Object System.Collections.ArrayList

<#
For each folder you wish to have dotsourced, copy the below example code block.
- Be sure to change the regex string to match the absolute path
  - this is just changing the word TEMPLATES to whatever the folder is called
- The ScriptType property on the next line is how this group folder should be referred to 
  in the $DotSourcelessScriptsBlock.Type property

# get every script inside the TEMPLATES folder (repeat this process for each folder of scripts)
$TEMPLATESfolder = Get-ChildItem -Path .\TEMPLATES\
# parsing out the html for just the scripts in the TEMPLATESfolder (regex skipping any _*.ps1 scripts)
$TEMPLATESScripts = $TEMPLATESfolder | Where-Object {$_.FullName -match '^.*TEMPLATES\\(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)$'}
$TEMPLATESScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "TEMPLATE"
# Adding our scripts into the main ArrayList
$DotSourcelessScripts.AddRange(@($TEMPLATESScripts)) | Out-Null
#>

# get every script inside the Classes folder (repeat this process for each folder of scripts)
$classfolder = Get-ChildItem -Path .\Classes\
# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$ClassScripts = $classfolder | Where-Object {$_.FullName -match '^.*Classes\\(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)$'}
$ClassScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Class"
# Adding our scripts into the main ArrayList
$DotSourcelessScripts.AddRange(@($ClassScripts)) | Out-Null

# get every script inside the Functions folder (repeat this process for each folder of scripts)
$functionfolder = Get-ChildItem -Path .\Functions\
# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$FunctionScripts = $functionfolder | Where-Object {$_.FullName -match '^.*Functions\\(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)$'}
$FunctionScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Function"
# Adding our scripts into the main ArrayList
$DotSourcelessScripts.AddRange(@($FunctionScripts)) | Out-Null

# creating a ScriptBlock ArrayList
$DotSourcelessScriptBlocks = New-Object System.Collections.ArrayList

# for each script found
foreach ($script in $DotSourcelessScripts)
{
    # get the contents of the script
    $scriptcontents = Get-Content $script.FullName -Raw

    # new temp object for the ScriptBlock ArrayList
    $obj = New-Object PSCustomObject

    # getting the scriptblock
    $scriptblock = ([ScriptBlock]::Create(($scriptcontents)))

    # setting properties
    $obj | Add-Member -MemberType NoteProperty -Name Name        -Value $script.Name
	$obj | Add-Member -MemberType NoteProperty -Name Type        -Value $script.ScriptType
    $obj | Add-Member -MemberType NoteProperty -Name Path        -Value $script.FullName
    $obj | Add-Member -MemberType NoteProperty -Name ScriptBlock -Value $scriptblock

    # adding our temp object to our ArrayList
    $DotSourcelessScriptBlocks.Add($obj) | Out-Null

    # and dot source it
    . $scriptblock
}# foreach ($script in $DotSourcelessScripts)

# setting our ScriptBlock ArrayList to global
$global:DotSourcelessScriptBlocks = $DotSourcelessScriptBlocks

#######################################
#endregion ############################
#######################################