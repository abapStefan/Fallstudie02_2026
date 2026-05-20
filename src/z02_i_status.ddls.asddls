@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status CDS'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.resultSet.sizeCategory: #XS // This triggers a dropdown menu instead of a popup dialog

define view entity Z02_I_STATUS
  as select from z02status
{
  @UI.lineItem: [{ position: 10 }]
  key status as Status
      //      @Semantics.user.createdBy: true
      //      created_by            as CreatedBy,
      //      @Semantics.systemDateTime.createdAt: true
      //      created_at            as CreatedAt,
      //      @Semantics.user.localInstanceLastChangedBy: true
      //      local_last_changed_by as LocalLastChangedBy,
      //      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      //      local_last_changed_at as LocalLastChangedAt,
      //      @Semantics.systemDateTime.lastChangedAt: true
      //      last_changed_at       as LastChangedAt
}
