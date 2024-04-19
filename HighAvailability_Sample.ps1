# DECLARE GLOBAL VARIABLES
$locationWest = 'westus'
$locationEast = 'eastus2'
$plan = 'hademo'
$resourceGroupNameWest = 'rghademowestus'
$resourceGroupNameEast = 'rghademoeastus2'
$serverName = 'calichinprimaryhademosqlserver'
$secondaryServerName = 'calichinsecondaryhademosqlserver'
$databaseName = 'hademotest'
$appServiceApp1 = 'calichinhademo-webapp-westus'
$appServiceApp2 = 'calichinhademo-webapp-eastus2'
$userName = 'mauricio'
$password = 'StArbUcksTh3B3st'


az login

az account show


#CREATING PRIMARY RESOURCES
# Create Resource Group
az group create --name $resourceGroupNameWest --location $locationWest

# Create Sql Server
az sql server create -l $locationWest -g $resourceGroupNameWest -n $serverName -u $userName -p $password

# Create Sql Server Firewall
az sql server firewall-rule create --name allowingall --server $serverName --resource-group $resourceGroupNameWest --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

# Create Sql Database
az sql db create --resource-group $resourceGroupNameWest --server $serverName --name $databaseName --edition Standard --zone-redundant false --backup-storage-redundancy Local 

# Create App Service Plan
az appservice plan create --name $plan --resource-group $resourceGroupNameWest --location $locationWest --sku S1

# Create App Service WebApp 
az webapp create --name $appServiceApp1 --plan $plan --resource-group $resourceGroupNameWest


# CREATING SECONDARY RESOURCES
# Create Resource Group
az group create --name $resourceGroupNameEast --location $locationEast

# Create Sql Server
az sql server create -l $locationEast -g $resourceGroupNameEast -n $secondaryServerName -u $userName -p $password

# Create Sql Server Firewall
az sql server firewall-rule create --name allowingall --server $secondaryServerName --resource-group $resourceGroupNameEast --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

# Create App Service Plan
az appservice plan create --name $plan --resource-group $resourceGroupNameEast --location $locationEast --sku S1

# Create App Service WebApp 
az webapp create --name $appServiceApp2 --plan $plan --resource-group $resourceGroupNameEast


# GO TO THE PORTAL AND SELECT THE SQL SERVER primaryhademosqlserver
# ON THE LEFT HAND SIDE SELECT FAILOVER GROUP
# Create Failover group using the following name : calichinhademotest-fg.database.windows.net
# Select the Server: secondaryhademosqlserver
# use default values and hit create


# TO DEMO - use SSMS or Azure Data Studio or Azure Portal 
# Open the primary server and create a test table named: TestUsers with Id, Name, and Role Name columns
# add couple of sample records
# primaryhademosqlserver.database.windows.net
# CREATE TABLE TestUsers (ID int identity(1,1) NOT NULL, Name varchar(50), RoleName varchar(50))
# INSERT TestUsers (Name, RoleName) VALUES ('Sharon', 'Accountant')
# INSERT TestUsers (Name, RoleName) VALUES ('Robert', 'Scrum Master')
# INSERT TestUsers (Name, RoleName) VALUES ('Peter', 'QA')
# SELECT * FROM TestUsers


# wait for a moment then connect to secondaryhademosqlserver server 
# confirm that the table has been replicated

# ADD APPROPRIATE SETTINGS FOR DB CONFIGURATION

az webapp config appsettings set -g $resourceGroupNameWest --name $appServiceApp1 --settings DatabaseServer=calichinhademotest-fg.database.windows.net
az webapp config appsettings set -g $resourceGroupNameEast --name $appServiceApp2 --settings DatabaseServer=calichinhademotest-fg.database.windows.net
az webapp config appsettings set -g $resourceGroupNameWest --name $appServiceApp1 --settings Region="WestUS-Primary"
az webapp config appsettings set -g $resourceGroupNameEast --name $appServiceApp2 --settings Region="EastUS-Secondary"

# Validate in the AppSettings configuration of each web app