#!/bin/bash

# Variables
RESOURCE_GROUP="<INSERT_Azure_RG_HERE>"
NEW_SKU="Standard_LRS" # Use Standard_LRS for Standard HDD or StandardSSD_LRS for Standard SSD
UTC_SHUTDOWN_TIME="09:00"

# Get the list of VMs in the resource group
VM_LIST=$(az vm list --resource-group $RESOURCE_GROUP --query "[].name" -o tsv)

echo "Here is the list of VM's in the resource group $RESOURCE_GROUP"
for vm in $VM_LIST
do
  echo "$vm"
done

# Questions
read -p "Do you want to enable Auto-Shutdown on all VMs in resource group $RESOURCE_GROUP at $UTC_SHUTDOWN_TIME UTC? (Y/N): " autoshutanswer
read -p "Do you want to change the disk type for all VM's in $RESOURCE_GROUP to Standard HDD? (Y/N): " diskanswer
read -p "Do you want to start all VM's in $RESOURCE_GROUP? (Y/N): " startanswer


# Enable Auto Shutdown on VM's
if [[ "$autoshutanswer" == [Yy] ]]; then
    echo "Enabling Auto-Shutdown on all VM's in resource group $RESOURCE_GROUP"

for vm in $VM_LIST
do
  echo "$vm"
    az vm auto-shutdown --resource-group $RESOURCE_GROUP --name $vm --on --time $UTC_SHUTDOWN_TIME --output none
done
else
    echo "Skipping Auto-Shutdown configuration."
fi

# Change disk type
if [[ "$diskanswer" == [Yy] ]]; then
    echo "Chaning disk to Standard HDD on all VM's in resource group $RESOURCE_GROUP"

# Iterate over each VM
for VM_NAME in $VM_LIST; do
    echo "Processing VM: $VM_NAME"

    # Deallocate the VM
    az vm deallocate --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo "Deallocated VM: $VM_NAME"

    # Get OS disk ID
    OS_DISK_ID=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "storageProfile.osDisk.managedDisk.id" -o tsv)

    # Change the OS disk SKU
    if [ ! -z "$OS_DISK_ID" ]; then
        az disk update --sku $NEW_SKU --ids $OS_DISK_ID --output none
        echo "Updated OS disk for VM: $VM_NAME to $NEW_SKU"
    fi

    # Get Info data disks
    DATA_DISK_IDS=$(az vm show --resource-group $RESOURCE_GROUP --name $VM_NAME --query "storageProfile.dataDisks[].managedDisk.id" -o tsv)

    # Change the data disk SKUs
    for DISK_ID in $DATA_DISK_IDS; do
        if [ ! -z "$DISK_ID" ]; then
            az disk update --sku $NEW_SKU --ids $DISK_ID --output none
            echo "Updated data disk $DISK_ID for VM: $VM_NAME to $NEW_SKU"
        fi
    done
echo "All disks in the resource group $RESOURCE_GROUP have been updated to $NEW_SKU."
done

else
    echo "Skipping disk configuration type."
fi


#Start All VM's in resource group
if [[ "$startanswer" == [Yy] ]]; then
    echo "Starting all VM's in resource group $RESOURCE_GROUP"

for VM_NAME in $VM_LIST; do
    # Start the VM
    az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME
    echo "Started VM: $VM_NAME"
done

else
    echo "Skipping VM Start configuration."
fi

