#######################################
#region ### MAIN ######################
#######################################


# get every script inside the Classes folder
$classfolder = Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/dnlrv/DotSourceless/tree/main/Classes'

# get every script inside the Functions folder
$functionfolder = Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/dnlrv/DotSourceless/tree/main/Functions'

# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$ClassScripts = ($classfolder.RawContent -replace '\s','') | Select-String 'Classes\/(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)' -AllMatches | foreach {$_.matches.Value -replace 'Classes\/(.*)','$1'} | Sort-Object -Unique
$ClassScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Class"

# parsing out the html for just the scripts in the classfolder (regex skipping any _*.ps1 scripts)
$FunctionScripts = ($functionfolder.RawContent -replace '\s','') | Select-String 'Functions\/(?!_)([a-zA-Z]+\-?[a-zA-Z]+\.ps1)' -AllMatches | foreach {$_.matches.Value -replace 'Functions\/(.*)','$1'} | Sort-Object -Unique
$FunctionScripts | Add-Member -MemberType NoteProperty -Name "ScriptType" -Value "Function"

# ArrayList to put all our scripts into
$DotSourcelessScripts = New-Object System.Collections.ArrayList
$DotSourcelessScripts.AddRange(@($ClassScripts)) | Out-Null
$DotSourcelessScripts.AddRange(@($FunctionScripts)) | Out-Null

# creating a ScriptBlock ArrayList
$DotSourcelessScriptBlocks = New-Object System.Collections.ArrayList

# for each script found in $ClassScripts
foreach ($script in $DotSourcelessScripts)
{
    # format the uri
    $uri = ("https://raw.githubusercontent.com/dnlrv/DotSourceless/main/{0}/{1}" -f $script.ScriptType, $script)

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
