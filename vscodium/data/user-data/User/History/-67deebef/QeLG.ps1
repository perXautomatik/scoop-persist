
function get-Origin
{
		# Get the remote url of the git repository
		$ref = (git remote get-url origin)

		# Write some information to the console
		Write-Verbos '************************** ref *****************************'
		Write-Verbos $ref.ToString()
		Write-Verbos '************************** ref *****************************'
		return $ref
}

function get-Relative {
	param (
		$path
		,$targetFolder
	)
	Set-Location $path
	$gitRoot = Get-GitRoot

	# Get the relative path of the target folder from the root of the git repository
	return (Resolve-Path -Path $targetFolder.FullName -Relative).TrimStart('.\').Replace('\', '/')

	# Write some information to the console
	Write-Verbos '******************************* bout to read as submodule ****************************************'
	Write-Verbos $relative.ToString()
	Write-Verbos $ref.ToString()
	Write-Verbos '****************************** relative path ****************************************************'

}

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


	function index-Remove ($name,$path)
	{
		try {
			# Change to the parent path and forget about the files in the target folder
			Set-Location $path
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
	}

	function about-Repo()
	{

			$vb = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

				# Write some information to the console
			Write-Verbos '************************************************************' -Verbose: $vb
			Write-Verbos $targetFolder.ToString() -Verbose: $vb
			Write-Verbos $name.ToString() -Verbose: $vb
			Write-Verbos $path.ToString() -Verbose: $vb
			Write-Verbos $configFile.ToString() -Verbose: $vb
			Write-Verbos '************************************************************'-Verbose: $vb

	}


<#
.SYNOPSIS
Gets the paths of all submodules in a git repository.
.DESCRIPTION
Gets the paths of all submodules in a git repository by parsing the output of git ls-files --stage.

.OUTPUTS
System.String[]
#>
function Get-SubmodulePaths {
    # run git ls-files --stage and filter by mode 160000
    git ls-files --stage | Select-String -Pattern "^160000"

    # loop through each line of output
    foreach ($Line in $Input) {
	# split the line by whitespace and get the last element as the path
	$Line -split "\s+" | Select-Object -Last 1
    }
}

<#
.SYNOPSIS
Gets the absolute path of the .git directory for a submodule.

.DESCRIPTION
Gets the absolute path of the .git directory for a submodule by reading the .git file and running git rev-parse --absolute-git-dir.

.PARAMETER Path
The path of the submodule.

.OUTPUTS
System.String
#>
function Get-GitDir {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # read the .git file and get the value after "gitdir: "
    $GitFile = Get-Content -Path "$Path/.git"
    $GitDir = $GitFile -replace "^gitdir: "

    # run git rev-parse --absolute-git-dir to get the absolute path of the .git directory
    git -C $Path rev-parse --absolute-git-dir | Select-Object -First 1
}

<#
.SYNOPSIS
Unsets the core.worktree configuration for a submodule.

.DESCRIPTION
Unsets the core.worktree configuration for a submodule by running git config --local --path --unset core.worktree.

.PARAMETER Path
The path of the submodule.
#>
function Unset-CoreWorktree {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # run git config --local --path --unset core.worktree for the submodule
    git --work-tree=$Path --git-dir="$Path/.git" config --local --path --unset core.worktree
}

<#
.SYNOPSIS
Hides the .git directory on Windows.

.DESCRIPTION
Hides the .git directory on Windows by running attrib.exe +H /D.

.PARAMETER Path
The path of the submodule.
#>
function Hide-GitDir {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # check if attrib.exe is available on Windows
    if (Get-Command attrib.exe) {
	# run attrib.exe +H /D to hide the .git directory
	MSYS2_ARG_CONV_EXCL="*" attrib.exe "+H" "/D" "$Path/.git"
    }
}


<# .SYNOPSIS
Lists all the ignored files that are cached in the index.

.DESCRIPTION
This function uses git ls-files with the -c, --ignored and --exclude-standard options to list all the files that are ignored by
Use git ls-files with the -c, --ignored and --exclude-standard options
.gitignore or other exclude files, and also have their content cached in the index. #>
function Get-IgnoredFiles {


git ls-files -s --ignored --exclude-standard -c }


<# .SYNOPSIS
Removes files from the index and the working tree.

.DESCRIPTION
This function takes an array of file names as input and uses git rm to remove them from the index and the working tree.
Define a function that removes files from the index and the working tree
.PARAMETER
 Files An array of file names to be removed. #>
function Remove-Files { param( # Accept an array of file names as input
[string[]]$Files )

#Use git rm with the file names as arguments
git rm $Files --ignore-unmatch }

<# .SYNOPSIS
Rewrites the history of the current branch by removing all the ignored files.

.DESCRIPTION
This function uses git filter-branch with the -f, --index-filter and --prune-empty options to rewrite the history of the current branch by removing all the ignored files from each revision, and also removing any empty commits that result from this operation. It does this by modifying only the index, not the working tree, of each revision.
#Define a function that rewrites the history of the current branch by removing all the ignored files
#Use git filter-branch with the -f, --index-filter and --prune-empty options#>

function Rewrite-History {    # Call the Get-IgnoredFiles function and pipe the output to Remove-Files function

    git filter-branch -f --index-filter {
	Get-IgnoredFiles | Remove-Files
	} --prune-empty }

#Call the Rewrite-History function
<# .SYNOPSIS
Lists all the ignored files that are cached in the index.

.DESCRIPTION
This function uses git ls-files with the -c, --ignored and --exclude-standard options to list all the files that are ignored by
Use git ls-files with the -c, --ignored and --exclude-standard options
.gitignore or other exclude files, and also have their content cached in the index. #>
function Get-IgnoredFiles {


git ls-files -s --ignored --exclude-standard -c }


<# .SYNOPSIS
Removes files from the index and the working tree.

.DESCRIPTION
This function takes an array of file names as input and uses git rm to remove them from the index and the working tree.
Define a function that removes files from the index and the working tree
.PARAMETER
 Files An array of file names to be removed. #>
function Remove-Files { param( # Accept an array of file names as input
[string[]]$Files )

#Use git rm with the file names as arguments
git rm $Files --ignore-unmatch }

<# .SYNOPSIS
Rewrites the history of the current branch by removing all the ignored files.

.DESCRIPTION
This function uses git filter-branch with the -f, --index-filter and --prune-empty options to rewrite the history of the current branch by removing all the ignored files from each revision, and also removing any empty commits that result from this operation. It does this by modifying only the index, not the working tree, of each revision.
#Define a function that rewrites the history of the current branch by removing all the ignored files
#Use git filter-branch with the -f, --index-filter and --prune-empty options#>

function Rewrite-History {    # Call the Get-IgnoredFiles function and pipe the output to Remove-Files function

    git filter-branch -f --index-filter {
	Get-IgnoredFiles | Remove-Files
	} --prune-empty }

#Call the Rewrite-History function Rewrite-History

# A function that parses the output of git ls-tree command and returns a custom object with properties
function Parse-GitLsTreeOutput
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTreeOutput
        )
        process {
            # Extract the blob type from the output line
            $blobType = $_.substring(7,4)
            # Set the hash start position based on the blob type
            $hashStartPos = 12
            if ($blobType -ne 'blob') { $hashStartPos+=2 } 
            # Set the relative path start position based on the blob type
            $relativePathStartPos = 53
            if ($blobType -ne 'blob') { $relativePathStartPos+=2 } 
            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unknown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     } 
}

# A function that resolves the absolute path of a file from its relative path
function Resolve-AbsolutePath
{
    param(
        [Parameter(Mandatory)] [string]$RelativePath
    )
    
    # Escape the backslash character for regex matching
    $backslash = [regex]::escape('\')
    
    # Define a regex pattern for matching octal escape sequences in the relative path
    $octalPattern = $backslash+'\d{3}'+$backslash+'\d{3}'
    
    # Trim the double quotes from the relative path
    $relativePath =  $RelativePath.Trim('"')

    # Try to resolve the relative path to an absolute path
    $absolutePath = Resolve-Path $relativePath -ErrorAction SilentlyContinue  
    
    # If the absolute path is not found and the relative path contains octal escape sequences, try to resolve it with wildcard matching
    if(!$absolutePath -and $relativePath -match ($octalPattern))
    { 
       $absolutePath = Resolve-Path  (($relativePath -split($octalPattern) ) -join('*')) 
    }
    # Return the absolute path or null if not found
    return $absolutePath     
}

# A function that takes a collection of parsed git ls-tree output objects and adds more properties to them such as absolute path, file name and parent folder
function Add-MorePropertiesToGitLsTreeOutput
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # For each object in the collection, add more properties using calculated expressions
    $GitLsTreeOutputObjects | Select-Object -Property *,@{Name = 'absolute'; Expression = {Resolve-AbsolutePath $_.relativePath}},@{Name = 'FileName'; Expression = {$path = $_.absolute;$filename = [System.IO.Path]::GetFileNameWithoutExtension("$path");if(!($filename)) { $filename = [System.IO.Path]::GetFileName("$path") };$filename}},@{Name = 'Parent'; Expression = {Split-Path -Path $_.relativePath}}
}

# A function that joins two collections of parsed git ls-tree output objects based on their file names and returns a custom object with properties for hash and absolute paths of both collections
function Join-GitLsTreeOutputCollectionsByFileName
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Collection1,
        [Parameter(Mandatory)]
        [psobject[]]$Collection2
    )
    # Define a delegate function that returns the file name of an object as the join key
    $KeyDelegate = [System.Func[Object,string]] {$args[0].FileName}
    # Define a delegate function that returns a custom object with properties for hash and absolute paths of both collections as the join result
    $resultDelegate = [System.Func[Object,Object,Object]]{ 
                    param ($x,$y);
                    
                    New-Object -TypeName PSObject -Property @{
                    Hash = $x.hash;
                    AbsoluteX = $x.absolute;
                    AbsoluteY = $y.absolute
                    }
                }
    
    # Use LINQ Join method to join the two collections by file name and return an array of custom objects as the result
    $joinedDataset = [System.Linq.Enumerable]::Join( $Collection1, $Collection2, #tableReference
        
                                                     $KeyDelegate,$KeyDelegate, #onClause
                
                                                     $resultDelegate
    )
    $OutputArray = [System.Linq.Enumerable]::ToArray($joinedDataset)

    return $OutputArray
}

# A function that creates a lookup table from a collection of parsed git ls-tree output objects based on their hash values
function Create-LookupTableByHash
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # Define a delegate function that returns the hash value of an object as the lookup key
    $HashDelegate = [system.Func[Object,String]] { $args[0].hash }
    # Define a delegate function that returns the object itself as the lookup element
    $ElementDelegate = [system.Func[Object]] { $args[0] }
    # Use LINQ ToLookup method to create a lookup table from the collection by hash value and return an array of lookup groups as the result
    $lookup = [system.Linq.Enumerable]::ToLookup($GitLsTreeOutputObjects, $HashDelegate,$ElementDelegate)

    return [Linq.Enumerable]::ToArray($lookup)
}


# This function takes an array of objects and splits it into smaller chunks of a given size
# It also executes a script block on each chunk if provided
function Split-Array
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)] [object[]] $InputObject,
        [Parameter()] [scriptblock] $Process,
        [Parameter()] [int] $ChunkSize
    )

    Begin { #run once
        # Initialize an empty array to store the chunks
        $cache = @();
        # Initialize an index to keep track of the chunk size
        $index = 0;
    }
    Process { #run each entry

        if($cache.Length -eq $ChunkSize) {
            # if the cache array is full, send it out to the pipe line
            write-host '{'  –NoNewline
            write-host $cache –NoNewline
            write-host '}'

            # Then we add the current pipe line object to the cache array and reset the index
            $cache = @($_);
            $index = 1;
        }
        else {
            # Otherwise, we append the current pipe line object to the cache array and increment the index
            $cache += $_;
            $index++;
        }

      }
    End { #run once
        # Here we check if there are any remaining objects in the cache array, if so, send them out to pipe line
        if($cache) {
            Write-Output ($cache );
        }
    }
}

# This function parses the output of git ls-tree and converts it into a custom object with properties
function Parse-LsTree
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTree
        )
        process {
            # Extract the blob type from the input string
            $blobType = $_.substring(7,4)
            # Set the starting positions of the hash and relative path based on the blob type
            $hashStartPos = 12
            $relativePathStartPos = 53

            if ($blobType -ne 'blob')
                {
                $hashStartPos+=2
                $relativePathStartPos+=2
                } 

            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

# This function lists the duplicate object hashes in a git repository using git ls-tree and Parse-LsTree functions
function List-Git-DuplicateHashes
{
    param([string]$path)
    # Save the current working directory
    $current = $PWD

    # Change to the given path
    cd $path

    # Use git ls-tree to list all the objects in the HEAD revision
    git ls-tree -r HEAD |
    # Parse the output using Parse-LsTree function
    Parse-LsTree |
            # Group the objects by hash and filter out the ones that have only one occurrence 
            Group-Object -Property hash |
            ? { $_.count -ne 1 } | 
            # Sort the groups by count in descending order
                Sort-Object -Property count -Descending

    # Change back to the original working directory            
    cd $current
 }               

# This function adds an index property to each object in an array using a counter variable 
function Add-Index { #https://stackoverflow.com/questions/33718168/exclude-index-in-powershell
   
    begin {
        # Initialize the counter variable as -1
        $i=-1
    }
   
    process {
        if($_ -ne $null) {
        # Increment the counter variable and add it as an index property to the input object 
        Add-Member Index (++$i) -InputObject $_ -PassThru
        }
    }
}

# This function displays the indexed groups of duplicate hashes in a clear format 
function Show-Duplicates
{    
    [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )

     Clear-Host
     Write-Host "================ k for keep all ================"
                 

    # Add an index property to each group using Add-Index function 
    $indexed = ( $input |  %{$_.group} | Add-Index )
            
    # Display the index and relative path of each group and store the output in a variable 
    $indexed | Tee-Object -variable re |  
    % {
        $index = $_.index
        $relativePath = $_.relativePath 
        Write-Host "$index $relativePath"
    }

    # Return the output variable 
    $re
}

# This function allows the user to choose which duplicate hashes to keep or delete 
function Choose-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
       # Split the input array into smaller chunks using Split-Array function 
       $options = $input | %{$_.index} | Split-Array 
       # Prompt the user to choose from the alternatives and store the input in a variable 
       $selection = Read-Host "choose from the alternativs " ($input | measure-object).count
       # If the user chooses to keep all, return nothing 
       if ($selection -eq 'k' ) {
            return
        } 
        else {
            # Otherwise, filter out the objects that have the same index as the selection and store them in a variable 
            $q = $input | ?{ $_.index -ne $selection }
        } 
    
       # Return the filtered variable 
       $q
}

# This function deletes the chosen duplicate hashes using git rm command 
function Delete-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
    if($input -ne $null)
    {

       # Split the input array into smaller chunks using Split-Array function 
       $toDelete = $input | %{$_.relativepath} | Split-Array 
       
       # For each chunk, use git rm to delete the files 
       $toDelete | % { git rm $_ } 

       # Wait for 2 seconds before proceeding 
       sleep 2
    }
}