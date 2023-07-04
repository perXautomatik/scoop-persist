﻿function Get-Commits {
    param (
        # The date parameter specifies the cut-off date for the commits
        [Parameter(Mandatory=$true)]
        [string]$Date
    )
    # Use git log to get all commit hashes before the date in a table format
    $commits = git log --all --before="$Date" --pretty=format:"%H"
    # Return the table of commits
    return $commits
}

# Define a function to search for a string in a commit using git grep
function Search-Commit {
    param (
        # The commit parameter specifies the commit hash to search in
        [Parameter(Mandatory=$true)]
        [string]$Commit,
        # The string parameter specifies the string to search for
        [Parameter(Mandatory=$true)]
        [string]$String
    )
    # Use git grep to search for the string in the commit and return a boolean value
    $result = git grep --ignore-case --word-regexp --fixed-strings -o $String -- $Commit
    return $result
}

# Define a function to search for a string in a commit using git log and regex
function Search-Commit-Regex {
    param (
        # The commit parameter specifies the commit hash to search in
        [Parameter(Mandatory=$true)]
        [string]$Commit,
        # The regex parameter specifies the regex pattern to search for
        [Parameter(Mandatory=$true)]
        [string]$Regex
    )
    # Use git log to search for the regex pattern in the commit and return a boolean value
    $result = git log -G $Regex -- $Commit
    return $result
}

# Define a function to create a hash table of commits and their frequencies of matching the search string
function Get-HashTable {
    param (
        # The commits parameter specifies the table of commits to process
        [Parameter(Mandatory=$true)]
        [array]$Commits,
        # The string parameter specifies the string to search for in each commit
        [Parameter(Mandatory=$true)]
        [string]$String,
        # The regex parameter specifies whether to use regex or not for searching (default is false)
        [Parameter(Mandatory=$false)]
        [bool]$Regex = $false
    )
    # Create an empty hash table to store the results
    $hashTable = @{}
    # Loop through each commit in the table of commits
    foreach ($commit in $commits) {
        # If regex is true, use Search-Commit-Regex function, otherwise use Search-Commit function
        if ($Regex) {
            $match = Search-Commit-Regex -Commit $commit -Regex $String
        }
        else {
            $match = Search-Commit -Commit $commit -String $String
        }
        # If there is a match, increment the frequency of the commit in the hash table, otherwise set it to zero
        if ($match) {
            $hashTable[$commit]++
        }
        else {
            $hashTable[$commit] = 0
        }
    }
    # Return the hash table of commits and frequencies
    return $hashTable
}

# Define a function to display a progress bar while processing a table of commits
function Show-Progress {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Commits,
        # The activity parameter specifies the activity name for the progress bar (default is "Searching Events")
        [Parameter(Mandatory=$false)]
        [string]$Activity = "Searching Events",
        # The status parameter specifies the status name for the progress bar (default is "Progress:")
        [Parameter(Mandatory=$false)]
        [string]$Status = "Progress:"
    )
    # Set the counter variable to zero
    $i = 0
    # Loop through each commit in the table of commits
    foreach ($commit in $commits) {
        # Increment the counter variable
        $i = $i + 1
        # Determine the completion percentage
        $Completed = ($i / $commits.count * 100)
        # Use Write-Progress to output a progress bar with the activity and status parameters
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $Completed
    }
}

I can try to fix the parameter block and turn this into a function with a synopsis. Here is my attempt:

<#
.SYNOPSIS
This function searches for a string in a repository of SQL files and returns a hash table of commits and frequencies of matching the string.

.DESCRIPTION
This function takes four parameters: repoPath, fileName, searchString and date. It uses the Tokenization.ps1 script to tokenize the SQL files in the repository. It then uses git commands to get all commits before the date and search for the string in each commit using regex. It creates a hash table of commits and frequencies of matching the string and sorts it in descending order. It also displays a progress bar while processing the table of commits.

.PARAMETER repoPath
The path to the repository of SQL files.

.PARAMETER fileName
The name of the SQL file to search in.

.PARAMETER searchString
The string to search for in the SQL file.

.PARAMETER date
The cut-off date for the commits.

.EXAMPLE
Search-Repository -repoPath 'D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\' -fileName 'harAnsökan (3).sql' -searchString "utanOnÃ¶digaHandlingar" -date "2020-03-02"

This example searches for the string "utanOnÃ¶digaHandlingar" in the file "harAnsökan (3).sql" in the repository "D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\" and returns a hash table of commits and frequencies before the date "2020-03-02".
#>
function Search-Repository {
    # Clear the screen
    cls

    # Define the parameters for the function
    param(
        # The repoPath parameter specifies the path to the repository of SQL files
        [Parameter(Mandatory=$true)]
        [string]$repoPath,
        # The fileName parameter specifies the name of the SQL file to search in
        [Parameter(Mandatory=$true)]
        [string]$fileName,
        # The searchString parameter specifies the string to search for in the SQL file
        [Parameter(Mandatory=$true)]
        [string]$searchString,
        # The date parameter specifies the cut-off date for the commits
        [Parameter(Mandatory=$true)]
        [string]$date
    )

    # Set the execution policy to bypass for the current user
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

    # Import the Tokenization.ps1 script from the network path
    . '\\100.84.7.151\NetBackup\Project Shelf\ToGit\PowerShellProjectFolder\scripts\TodoProjects\Tokenization.ps1'

    # Escape the search string for regex
    $regexSearchstring = [Regex]::Escape($searchString)

    # Change the current directory to the repository path
    cd $repoPath

    # Define a function to get all commits in the repository before a given date

    # Get all commits before the date using Get-Commits function and store them in a variable
    $mytable = Get-Commits -Date $date

    # Create a hash table of commits and frequencies using Get-HashTable function and store it in a variable
    $hashTable = Get-HashTable -Commits $mytable -String $searchString -Regex $true

    # Display a progress bar while processing the table of commits using Show-Progress function
    Show-Progress -Commits $mytable

    # Sort the hash table by frequency in descending order and display the results
    $hashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name
}