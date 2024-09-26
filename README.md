# AzureVM-ConfigTuner
This script makes bulk changes to all VM's in an Azure resource group.

Features:
- Set Auto shutdown on all VM's in an Azure Resource Group.
- Change disk type from Standard SSD to Standard HDD.
- Start all VM"s in a resource group.


#### Download Script
```
wget https://raw.githubusercontent.com/bradmcdowell/AzureVM-ConfigTuner/refs/heads/main/AzureVM-ConfigTuner.sh
```

#### Modify RESOURCE_GROUP variable on line 4
```
nano ./AzureVM-ConfigTuner.sh
```

#### Update AzureVM-ConfigTuner.sh to be executable

```
chmod +x ./AzureVM-ConfigTuner.sh
```

#### Run the script

```
./AzureVM-ConfigTuner.sh
```
