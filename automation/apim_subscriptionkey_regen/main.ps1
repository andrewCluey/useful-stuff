# Get API Management Services information
## Add in expression to get API Management in specific environment

$ApiManagements = Get-AzApiManagement 

foreach ($ApiManagement in $ApiManagements)
{
 #Setting Up Azure API Management Context to work. 
 $ApiManagementContext = New-AzApiManagementContext -ResourceId $ApiManagement.Id

# Get all API Management Subscriptions with specific ProductID
 $ApiManagementSubscriptions = Get-AzApiManagementSubscription -Context $ApiManagementContext -ProductId “unlimited”
 foreach ($ApiManagementSubscription in $ApiManagementSubscriptions)
 {
 # Regenerating Primary Key
 $PrimaryKey = (New-Guid) -replace ‘-’,’’
 
 #In Order to set a new value 
 $newvalue = Set-AzApiManagementSubscription -Context $ApiManagementContext -SubscriptionId $ApiManagementSubscription.SubscriptionId -PrimaryKey $PrimaryKey -State Active 
 $updatedvalue = Get-AzApiManagementSubscription -Context $ApiManagementContext -ProductId “unlimited” | select primarykey -ExpandProperty primarykey
 $updatedvalue
 }
}