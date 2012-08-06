[Void] [Reflection.Assembly]::LoadWithPartialName("System.Messaging")

function SetPermissions( $queue ) {
    $queue.SetPermissions(".\Administrators", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions("Everyone", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions("NETWORK SERVICE", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions("ANONYMOUS LOGON", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)

    $queue.SetPermissions("SYSTEM", [System.Messaging.MessageQueueAccessRights]::ReceiveMessage, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions("SYSTEM", [System.Messaging.MessageQueueAccessRights]::PeekMessage, [System.Messaging.AccessControlEntryType]::Allow)
    $queue.SetPermissions("SYSTEM", [System.Messaging.MessageQueueAccessRights]::WriteMessage, [System.Messaging.AccessControlEntryType]::Allow)

    $queue.SetPermissions("LOCAL SERVICE", [System.Messaging.MessageQueueAccessRights]::ReceiveMessage, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions("LOCAL SERVICE", [System.Messaging.MessageQueueAccessRights]::PeekMessage, [System.Messaging.AccessControlEntryType]::Allow)
    $queue.SetPermissions("LOCAL SERVICE", [System.Messaging.MessageQueueAccessRights]::WriteMessage, [System.Messaging.AccessControlEntryType]::Allow)

    $computer = "{0}$" -f $env:COMPUTERNAME
    
    $queue.SetPermissions($computer, [System.Messaging.MessageQueueAccessRights]::GetQueueProperties, [System.Messaging.AccessControlEntryType]::Set)
    $queue.SetPermissions($computer, [System.Messaging.MessageQueueAccessRights]::GetQueuePermissions, [System.Messaging.AccessControlEntryType]::Allow)
}

$queues = @(
	'abtesting_processor',
	'filtering_queue',
	'fwparams_processor',
	'healthcheck_queue', 
	'sandbox_queue', 
	'superbid_processor', 
	'tracking_processor'
)

$queues | %{
    $queuename = ".\private$\{0}" -f $_
    $qb = [System.Messaging.MessageQueue]::Create($queuename, $true)
    if ($qb -eq $null)
    {
        exit
    }
    $qb.label = $queuename
    
    SetPermissions $qb

}
