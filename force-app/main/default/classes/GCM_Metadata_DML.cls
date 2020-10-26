/****************************************************************************************************
 *  Date          : 8-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Class that creates metadata in the background.
 *                  Run asynchronously to avoid MIXED-DML-OPERATION error.
 *                  "process" method handles non metadata insert or update DMLs.
 *                  GCM_Metadata_DML class is the asynchronous object that runs metadata DMLs
 * Modifications  : 8-MAR-2019 SYAP - Initial
 *                  23-JUL-2019 SYAP - Added comments.
 *                  30-OCT-2019 SYAP - Added user call center update.
 ****************************************************************************************************/
 
public class GCM_Metadata_DML implements Queueable {
  private List<GroupMember> groupMemberInsert;
  private List<GroupMember> groupMemberDelete;
  private List<PermissionSetAssignment> permissionMemberInsert;
  private List<PermissionSetAssignment> permissionMemberDelete;
  private List<User> userRoleUpdate;
  private List<User> userCallCenterUpdate;

/****************************************************************************************************
  Constructor
 ****************************************************************************************************/
  public GCM_Metadata_DML(List<GroupMember> groupMemberInsert, List<GroupMember> groupMemberDelete, List<PermissionSetAssignment> permissionMemberInsert, List<PermissionSetAssignment> permissionMemberDelete, List<User> userRoleUpdate, List<User> userCallCenterUpdate) {
    this.groupMemberInsert = groupMemberInsert;
    this.groupMemberDelete = groupMemberDelete;
    this.permissionMemberInsert = permissionMemberInsert;
    this.permissionMemberDelete = permissionMemberDelete;
    this.userRoleUpdate = userRoleUpdate;
    this.userCallCenterUpdate = userCallCenterUpdate;
  }

/****************************************************************************************************
  Insert / Delete Metadata Asynchronously
 ****************************************************************************************************/
  public void execute(QueueableContext context) {
    if (groupMemberInsert.size() > 0) insert groupMemberInsert;
    if (groupMemberDelete.size() > 0) delete groupMemberDelete;
    if (permissionMemberInsert.size() > 0) insert permissionMemberInsert;
    if (permissionMemberDelete.size() > 0) delete permissionMemberDelete;
    if (userRoleUpdate.size() > 0) update userRoleUpdate;
    if (userCallCenterUpdate.size() > 0) update userCallCenterUpdate;
  }     
}