
function filterByName ($pattern)
{
    $filter = "";
    $filter = "git ls-files -x " +""""+ "$pattern" +""""+ " | xargs git rm -r "
    Write-Output ("|||" + $filter)
    $exec = "";
    Write-Output "--exec--"
    $exec = "git filter-branch --index-filter " +"'"+ "$filter" +"'"+ "--prune-empty --tag-name-filter cat -- --all"
    Write-Output ("||" + $exec)
    #$exec = $filter
    Invoke-Expression $exec
}