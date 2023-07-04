
function cherryPick-byPattern ($pattern)
{
    $latest = Invoke-Expression "git rev-parse HEAD"

    $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"
    
    $last = ( $hashesThatToutches | select -last 1 )
    $last 
    git checkout -b $pattern $last
    
}