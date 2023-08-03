# Define a function to sort a list using insertion sort
function checkPredicate($ax,$bx)
{
    # Check if either parameter is null
    if ($ax -eq $null -or $bx -eq $null) {
        # Return true
        return $false
    }
    # Otherwise, proceed with the original logic
    [string]$current = $ax
    [string]$sortedj = $bx
    [System.Boolean]$conclusion = $current.StartsWith($sortedj)
    return $conclusion
}

function Insertion-Sort {
    param($list)

    $unsorted = $list
    $sortedx = [System.Collections.ArrayList]@()

    $current = "";

    # Loop through the list from the second element
    for ($i = 0; $i -lt $unsorted.Count; $i++) {
        
        # Get the current element
        $current = $unsorted[$i]
        
                for($x = 0; $x -lt $sortedx.Length; $x++ )
                {
                    $verdict = checkPredicate $current $sortedx[$x]

                    if(($x -gt 0) -and ($x -lt $sortedx.Length) -and $verdict) # middle of array
                    {
                        $above = $sortedx | select -first $m
                        $below = $sortedx | select -Skip $j
                        
                        $sortedx.Clear()
                        $sortedx = $above+$current+$below
                    }                    
                    elseif (($x -eq 0) -and $verdict) { # begining of arrau
                        $sortedx = $current+$sortedx                        
                    }
                    elseif (($x -eq $sortedx.Length) -and ($sortedx.Length -gt 0)) { # end of array 
                        $sortedx = $sortedx+$current
                    }
                    else # empty array
                    {
                        $sortedx = $current
                    }
                }

            }

            



            # example a and ab
            if($verdict)
            {                    

            }
            else {                
                $sortedx.Add($current)                
            }            
            # Increment the index variable
            $j++
        # End the do while loop with the condition


    }        
    # Return the sorted list
    return $sortedx
}

# Define a sample list of numbers
$numbers = 28, 2, 11, 12, 5, 6, 7, 1

# Call the function to sort the list using insertion sort
$sorted = Insertion-Sort -list $numbers

# Display the sorted list
$sorted