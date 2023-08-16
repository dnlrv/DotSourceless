###########
#region ### Get-Actors # Multithread example
###########
function Get-Actors
{
    
    [CmdletBinding(DefaultParameterSetName="All")]
    param
    (
        [Parameter(Mandatory = $false, HelpMessage = "The names to create Actor objects.")]
        [System.String[]]$Names
    )
    # ArrayList to hold objects
    $returned = New-Object System.Collections.ArrayList

	# multithread start
	$RunspacePool = [runspacefactory]::CreateRunspacePool(1,12)
	$RunspacePool.ApartmentState = 'STA'
	$RunspacePool.ThreadOptions = 'ReUseThread'
	$RunspacePool.Open()
	
	# jobs ArrayList
	$Jobs = New-Object System.Collections.ArrayList

	foreach ($name in $Names)
	{
		$PowerShell = [PowerShell]::Create()
		$PowerShell.RunspacePool = $RunspacePool

		# Counter for the account objects
		$g++; Write-Progress -Activity "Getting objects" -Status ("{0} out of {1} Complete" -f $g,$Names.Count) -PercentComplete ($g/($Names | Measure-Object | Select-Object -ExpandProperty Count)*100)
		
		# for each script in our DotSourcelessScriptBlocks
		foreach ($script in $global:DotSourcelessScriptBlocks)
		{
			# add it to this thread as a script, this makes all classes and functions available to this thread
			[void]$PowerShell.AddScript($script.ScriptBlock)
		}

		# the script part itself
		[void]$PowerShell.AddScript(
		{
			Param
			(
				$name
			)
		
			$actor = New-Object Actor -ArgumentList ($name)
	
			return $actor
		})# [void]$PowerShell.AddScript(
		[void]$PowerShell.AddParameter('name',$name) # this passes the variable to the worker thread
		
		$JobObject = @{}
		$JobObject.Runspace   = $PowerShell.BeginInvoke()
		$JobObject.PowerShell = $PowerShell

		$Jobs.Add($JobObject) | Out-Null
	}# foreach ($name in $Names)

	foreach ($job in $jobs)
	{
		# Counter for the job objects
		$p++; Write-Progress -Activity "Processing objects" -Status ("{0} out of {1} Complete" -f $p,$jobs.Count) -PercentComplete ($p/($jobs | Measure-Object | Select-Object -ExpandProperty Count)*100)
		
		$returned.Add($job.powershell.EndInvoke($job.RunSpace)) | Out-Null
		$job.PowerShell.Dispose()
	}# foreach ($job in $jobs)

	# $returned gives back a System.Management.Automation.PSObject
	# so we'll need to recreate the original object back in our 
	# main thread to ensure we have our original class objects
	# this is very important if your classes have methods as the
	# automation object WON'T have those.
	
	$Actors = New-Object System.Collections.ArrayList

	foreach ($actor in $returned)
	{
		$obj = New-Object Actor $actor.Name

		$Actors.Add($obj) | Out-Null
	}

    #return $Actors
    return $Actors
}# function Get-Actors
#endregion
###########