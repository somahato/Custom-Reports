/*Remove host hardware */
BEGIN TRANSACTION T1

DECLARE @ComputerName AS NVARCHAR(50)
DECLARE @HostID AS NVARCHAR(50)
DECLARE @AgentServerID AS NVARCHAR(50)


/* set variables */
SET @ComputerName = 'BLRF3R03-005' /* Insert FQDN of host to be removed here */

SET @HostID = 
(
SELECT HostID FROM tbl_ADHC_Host
WHERE ComputerName = @ComputerName
)
SET @AgentServerID =
(
SELECT AgentServerID FROM tbl_ADHC_AgentServerRelation
WHERE HostLibraryServerID = @HostID
)


/*Start removal*/
/* Remove of HBA networking */
DELETE FROM tbl_ADHC_ISCSIHbaToPortalMapping
WHERE ISCSIHbaID in 
( 
SELECT hbaid FROM tbl_ADHC_HostBusAdapter
WHERE HostID = @HostID
)

DELETE FROM tbl_ADHC_ISCSIHbaToTargetMapping
WHERE ISCSIHbaID in 
( 
SELECT hbaid FROM tbl_ADHC_HostBusAdapter
WHERE HostID = @HostID
)

DELETE FROM tbl_ADHC_HostInternetSCSIHba
WHERE ISCSIHbaID in
( 
SELECT hbaid FROM tbl_ADHC_HostBusAdapter
WHERE HostID = @HostID
)
DELETE FROM tbl_ADHC_FCHbaToFibrePortMapping
WHERE FCHbaID in
(
 SELECT HBAId FROM tbl_adhc_HostBusAdapter
 WHERE HostID = @HostID
)

DELETE FROM tbl_ADHC_HostFibreChannelHba
WHERE FCHbaID in
(
 SELECT HbaID FROM tbl_adhc_HostBusAdapter
 WHERE HostID = @HostID
)

DELETE FROM tbl_ADHC_HostSASHba
WHERE SASHbaID in
(
 SELECT HBAId FROM tbl_adhc_HostBusAdapter
 WHERE HostID = @HostID
)
DELETE FROM tbl_adhc_HostBusAdapter
WHERE HbaID in
(
 SELECT HBAId FROM tbl_adhc_HostBusAdapter
 WHERE HostID = @HostID
)

/* Remove Host Networking */

DELETE FROM tbl_NetMan_HostNetworkAdapterToLogicalNetwork 
WHERE HostNetworkAdapterID in
(
SELECT NetworkAdapterID FROM tbl_ADHC_HostNetworkAdapter
WHERE HostID = @HostID
)
DELETE FROM tbl_ADHC_HostNetworkAdapter 
WHERE NetworkAdapterID in
(
SELECT NetworkAdapterID FROM tbl_ADHC_HostNetworkAdapter
WHERE HostID = @HostID
)

/*Remove host hardware */
DELETE FROM tbl_ADHC_VirtualNetwork 
WHERE HostID = @HostID
DELETE FROM tbl_ADHC_HostVolume 
WHERE HostID = @HostID
Delete FROM tbl_WLC_VDrive
WHERE HostDiskId in
(
SELECT diskid from tbl_ADHC_HostDisk 
Where HostID = @HostID 
) 
DELETE FROM tbl_ADHC_HostDisk 
WHERE HostID = @HostID
DELETE FROM tbl_WLC_PhysicalObject 
WHERE HostID = @HostID
DELETE FROM tbl_WLC_VObject 
WHERE HostID = @HostID

/* Remove references to host */

DELETE FROM tbl_ADHC_HealthMonitor
WHERE AgentServerID in
(
SELECT AgentServerID FROM tbl_ADHC_AgentServerRelation
WHERE HostLibraryServerID = @HostID
)
DELETE FROM tbl_ADHC_AgentServerRelation 
WHERE AgentServerID in
(
SELECT AgentServerID FROM tbl_ADHC_AgentServerRelation
WHERE HostLibraryServerID = @HostID
)
DELETE FROM tbl_ADHC_AgentServer 
WHERE AgentServerID = @AgentServerID

/*Remove physical machine info*/
DELETE from tbl_PMM_PhysicalMachine
WHERE PhysicalMachineID in
(
    SELECT PhysicalMachineID from tbl_ADHC_Host
    WHERE HostID = @HostID
)


/* Final host removal */
DELETE FROM tbl_ADHC_HostCluster
WHERE AvailableStorageHostID = @HostID
DELETE FROM tbl_NetMan_InstalledVirtualSwitchExtension
WHERE HostID = @HostID
DELETE FROM tbl_RBS_RunAsAccountConsumer 
WHERE ObjectID = @HostID
DELETE FROM tbl_VMMigration_EndpointLUNMapping 
WHERE EndPointID = @HostID
DELETE FROM tbl_ADHC_HostBusAdapter 
WHERE HostID = @HostID
Delete from tbl_ADHC_HostToProcessorCompatibilityVectorMapping
Where HOSTID = @HostID
DELETE FROM tbl_ADHC_Host 
WHERE HostID = @HostID

COMMIT TRANSACTION T1