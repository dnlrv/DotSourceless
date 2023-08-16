#######################################
#region ### MAIN ######################
#######################################

# ArrayList to put all our scripts into
$DotSourcelessScripts = New-Object System.Collections.ArrayList

<#
For each folder you wish to have dotsourced, copy the below example code block.
- Be sure to change the url to YOUR GitHub username/repo/branch/folder.
- Be sure to change the regex string to match the absolute path
- this is just changing the word TEMPLATES to whatever the folder is called
- The ScriptType property on the next line is how this group folder should be referred to 
  in the $DotSourcelessScriptsBlock.Type property

# get every script inside the TEMPLATES folder
$TEMPLATEfolder = Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/dnlrv/DotSourceless/tree/main/TEMPLATES'
# parsing out the html for just the scripts in the TEMPLATEfolder (regex skipping any _*.ps1 scripts)
$TEMPLATEScripts = ($TEMPLATEfolder.RawContent -replace '\s','') | Select-String 'TEMPLATES\/(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)' -AllMatches | foreach {$_.matches.Value -replace 'TEMPLATES\/(.*)','$1'} | Sort-Object -Unique
$TEMPLATEScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "TEMPLATE"
$TEMPLATEScripts | Add-Member -MemberType NoteProperty -Name FolderName -Value "TEMPLATES"
$DotSourcelessScripts.AddRange(@($TEMPLATEScripts)) | Out-Null
#>

# get every script inside the Classes folder
$classfolder = Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/dnlrv/DotSourceless/tree/main/Classes'
# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$ClassScripts = ($classfolder.RawContent -replace '\s','') | Select-String 'Classes\/(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)' -AllMatches | foreach {$_.matches.Value -replace 'Classes\/(.*)','$1'} | Sort-Object -Unique
$ClassScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Class"
$ClassScripts | Add-Member -MemberType NoteProperty -Name FolderName -Value "Classes"
$DotSourcelessScripts.AddRange(@($ClassScripts)) | Out-Null

# get every script inside the Functions folder
$functionfolder = Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/dnlrv/DotSourceless/tree/main/Functions'
# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$FunctionScripts = ($functionfolder.RawContent -replace '\s','') | Select-String 'Functions\/(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)' -AllMatches | foreach {$_.matches.Value -replace 'Functions\/(.*)','$1'} | Sort-Object -Unique
$FunctionScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Function"
$FunctionScripts | Add-Member -MemberType NoteProperty -Name FolderName -Value "Functions"
$DotSourcelessScripts.AddRange(@($FunctionScripts)) | Out-Null

# creating a ScriptBlock ArrayList
$DotSourcelessScriptBlocks = New-Object System.Collections.ArrayList

# for each script found in $ClassScripts
foreach ($script in $DotSourcelessScripts)
{
    # format the uri
    $uri = ("https://raw.githubusercontent.com/dnlrv/DotSourceless/main/{0}/{1}" -f $script.FolderName, $script)

    # new temp object for the ScriptBlock ArrayList
    $obj = New-Object PSCustomObject

    # getting the scriptblock
    $scriptblock = ([ScriptBlock]::Create(((Invoke-WebRequest -Uri $uri).Content)))

    # setting properties
    $obj | Add-Member -MemberType NoteProperty -Name Name        -Value (($script.Split(".")[0]))
	$obj | Add-Member -MemberType NoteProperty -Name Type        -Value $script.ScriptType
    $obj | Add-Member -MemberType NoteProperty -Name Uri         -Value $uri
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