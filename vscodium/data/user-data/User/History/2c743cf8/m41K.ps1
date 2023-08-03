﻿# Define the base path and the list of folder names
$basePath = "K:\D2RMM 1.4.5\mods"
$folderNames = "hd|global|excel|tiles|ui"

# Split the list of folder names by "|" and store them in an array
$folderNamesArray = $folderNames -split "\|"

# Use Get-ChildItem to get all the subfolders of the base path
# Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
$subfolders = Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue

# Create an empty array to store the output
$output = @()

# Loop through each subfolder in the base path
# Loop through each subfolder in the base path
foreach ($subfolder in $subfolders) {
  # Loop through each folder name in the array
  foreach ($folderName in $folderNamesArray) {
    # Use Get-ChildItem to search for the folder name in the subfolder recursively
    # Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
    # Use Select-Object -First 1 to get only the first occurrence of the folder
    $folder = Get-ChildItem -Path $subfolder.FullName -Filter $folderName -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    
    # If the folder is found, add its name and full path to the output array
    if ($folder) {
      $output += [PSCustomObject]@{
        Name = $folder.Name
        Path = $folder.FullName
      }
      # Break the inner loop and move on to the next subfolder
      Break
    }
  }
  # If a folder name was found, use Get-ChildItem again to search for the other folder names on the same level
  # Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
  # Use -Exclude to exclude the folder name that was found and search for the other names in the array
  if ($folder) {
    $otherFolders = Get-ChildItem -Path (Split-Path $folder.FullName) -Directory -ErrorAction SilentlyContinue -Exclude $folder.Name | Where-Object {$_.Name -in $folderNamesArray}
    
    # If any other folders are found, add their names and full paths to the output array
    if ($otherFolders) {
      foreach ($otherFolder in $otherFolders) {
        $output += [PSCustomObject]@{
          Name = $otherFolder.Name
          Path = $otherFolder.FullName
        }
      }
    }
  }
}


# Group the output by the folder name before the underscore character
# Use a script block as the value of the Property parameter to extract that part of the name
$qq = $output |  Group-Object -Property {Split-Path $_.Path -Parent}| ?{ (split-path -path $_.name -Leaf) -eq "data" } #| Format-Table -Property Name, Group -AutoSize -Wrap

# Define a function that takes a number of paths and a delimited list of words as parameters
function Remove-WordsFromParentFolders {
    param (
        [string[]]$Paths,
        [string]$Words
    )

    # Split the words by the delimiter and store them in an array
    $WordArray = $Words -split ","

    # Loop through each path in the Paths array
    foreach ($Path in $Paths) {
        # Get the parent folder name of the current path
        $ParentFolder = Split-Path $Path -Parent

        # Check if the parent folder name is entirely the word
        if ($ParentFolder -eq "out") {
            # Get the grandparent folder name of the current path
            $GrandParentFolder = Split-Path $ParentFolder -Parent
            # Set the parent folder name to the grandparent folder name
            $ParentFolder = $GrandParentFolder
        }

        # Loop through each word in the WordArray
        foreach ($Word in $WordArray) {
            # Check if the parent folder name contains the word
            if ($ParentFolder -match $Word) {
                # Remove the word from the parent folder name
                $ParentFolder = $ParentFolder -replace $Word, ""
            }
   
        }

        # Return the edited parent folder name
        return $ParentFolder
    }
}

# Example usage: provide some paths and a delimited list of words as arguments
Remove-WordsFromParentFolders -Paths $qq.name -Words "mpq,installing"