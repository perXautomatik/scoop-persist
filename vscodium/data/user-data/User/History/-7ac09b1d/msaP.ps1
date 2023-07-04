﻿<#todo
fallback solutions
* if everything fails,
    set got dir path to abbsolute value and edit work tree in place
* if comsumption fails,
    due to modulefolder exsisting, revert move and trye to use exsisting folder instead,
    if this ressults in error, re revert to initial
	move inplace module to x prefixed
	atempt to consume again
* if no module is provided, utelyse everything to find possible folders
    use hamming distance like priorit order
	where
	1. exact parrentmatch
	   rekative to root
	    order resukts by total exact


	take first precedance
	2. predefined patterns taken
	and finaly sort rest by hamming
#>

# This script converts a git folder into a submodule and absorbs its git directory

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage=".git, The path of the git folder to convert")][ValidatePath $_][Alias("GitFolder")][string]$errorus,[Parameter(Mandatory=$true,HelpMessage="subModuleRepoDir, The path of the submodule folder to replace the git folder")]
     #can be done with everything and menu
    [Parameter(Mandatory=$true,HelpMessage="subModuleDirInsideGit")][ValidatePath $_][Alias("SubmoduleFolder")][string]$toReplaceWith
)
begin {
	$pastE = $error
	$error.Clear()

	Try {
		$null = Resolve-Path -Path $errorus -ErrorAction Stop
		$null = Resolve-Path -Path $toReplaceWith -ErrorAction Stop
		$null = Test-Path -Path $errorus -ErrorAction Stop
		$null = Test-Path -Path $toReplaceWith -ErrorAction Stop
	}
	catch {
		Write-Error "paths was unresolvable"
		Write-Error $error		
	}
	# Save the previous error action preference
	$previousErrorAction = $ErrorActionPreference
	$ErrorActionPreference = "Stop"


	# Define a function to get the root of the git repository
	function Get-GitRoot {
	    (git rev-parse --show-toplevel)
	}
	
	function git-root {
		$gitrootdir = (git rev-parse --show-toplevel)
		if ($gitrootdir) {
			Set-Location $gitrootdir
		}
		}

	# Define a function to move a folder to a new destination
	function Move-Folder {
	    param (
		[Parameter(Mandatory=$true)][string]$Source,
		[ValidateScript({Test-Path $_})]
		# Check if the destination already exists
		[Parameter(Mandatory=$true, HelpMessage="Enter A empty path to move to")]
		[ValidateScript({!(Test-Path $_)})]
		[string]$Destination
	    )

	    try {
			Move-Item -Path $Source -Destination $Destination -ErrorAction Stop
			Write-Verbos "Moved $Source to $Destination"
	    }
	    catch {
			Write-Warning "Failed to move $Source to $Destination"
			Write-Warning $_.Exception.Message
	    }
	}

	# Define a function to add and absorb a submodule
	function Add-AbsorbSubmodule {
	    param (
		[Parameter(Mandatory=$true)]
		[string]$Ref,

		[Parameter(Mandatory=$true)]
		[string]$Relative
	    )

	    try {
		Git submodule add $Ref $Relative
		git commit -m "as submodule $Relative"
		Git submodule absorbgitdirs $Relative
		Write-Verbos "Added and absorbed submodule $Relative"
	    }
	    catch {
			Write-Warning "Failed to add and absorb submodule $Relative"
			Write-Warning $_.Exception.Message
	    }
	}
}
process {


# Get the target folder, name and parent path from the git folder
    Write-Verbos "#---- asFile"
	$asFile = ([System.IO.Fileinfo]$errorus.trim('\'))
	$childy = [System.IO.Fileinfo] $asFile.FullName
    Write-Verbos $asFile
	$targetFolder = $asFile.Directory
	$name = $targetFolder.Name
	$path = $targetFolder.Parent.FullName

	# Get the config file path from the git folder
	$configFile = Join-Path $GitFolder 'config'

	# Write some information to the console
	Write-Verbos '************************************************************'
	Write-Verbos $targetFolder.ToString()
	Write-Verbos $name.ToString()
	Write-Verbos $path.ToString()
	Write-Verbos $configFile.ToString()
	Write-Verbos '************************************************************'


	# Move the git folder to a temporary name
	Move-Folder -Source $GitFolder -Destination (Join-Path $targetFolder 'x.git')

	# Move the submodule folder to replace the git folder
	Move-Folder -Source $SubmoduleFolder -Destination (Join-Path $targetFolder '.git')

	# Remove the worktree line from the config file
	(Get-Content -Path $configFile | Where-Object { ! ($_ -match 'worktree') }) | Set-Content -Path $configFile

	# Push the current location and change to the target folder
	Push-Location
	Set-Location $targetFolder

	# Get the remote url of the git repository
	$ref = (git remote get-url origin)

	# Write some information to the console
	Write-Verbos '************************** ref *****************************'
	Write-Verbos $ref.ToString()
	Write-Verbos '************************** ref *****************************'

	# Change to the parent path and forget about the files in the target folder
	Set-Location $path

	try {
		# Check if the files in the target folder are already ignored by git
		if ((git ls-files --error-unmatch --others --exclude-standard --directory --no-empty-directory -- "$name") -eq "") {
		Write-Warning "The files in $name are already ignored by git"
		}
		else {
		git rm -r --cached $name
		git commit -m "forgot about $name"
		}
	}
	catch {
		Write-Warning "Failed to forget about files in $name"
		Write-Warning $_.Exception.Message
	}

	# Change to the parent path and get the root of the git repository
	Set-Location $path
	$gitRoot = Get-GitRoot

	# Get the relative path of the target folder from the root of the git repository
	$relative = (Resolve-Path -Path $targetFolder.FullName -Relative).TrimStart('.\').Replace('\', '/')

	# Write some information to the console
	Write-Verbos '******************************* bout to read as submodule ****************************************'
	Write-Verbos $relative.ToString()
	Write-Verbos $ref.ToString()
	Write-Verbos '****************************** relative path ****************************************************'

	# Add and absorb the submodule using the relative path and remote url
	Add-AbsorbSubmodule -Ref $ref -Relative $relative

	# Pop back to the previous location
	Pop-Location

	# Restore the previous error action preference
	$ErrorActionPreference = $previousErrorAction

}