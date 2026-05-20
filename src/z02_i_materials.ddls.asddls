@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Materials'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z02_I_MATERIALS
  as select from z02materials
{
      @UI.selectionField: [{ position: 10}]
      @UI.lineItem: [{ position: 10 }]
  key material_id   as MaterialId,
      @UI.lineItem: [{ position: 20 }]
      material_name as MaterialName,
      @UI.lineItem: [{ position: 30 }]
      @EndUserText.label: 'Material Price'
      @Semantics.amount.currencyCode : 'currency'
      price         as Price,
      @UI.hidden: true // This hides the column from the UI
      @Consumption.filter.hidden: true // Hidden from user, but available to the engine
      currency      as Currency
      //    @Semantics.user.createdBy: true
      //    created_by            as CreatedBy,
      //    @Semantics.systemDateTime.createdAt: true
      //    created_at            as CreatedAt,
      //    @Semantics.user.localInstanceLastChangedBy: true
      //    local_last_changed_by as LocalLastChangedBy,
      //    @Semantics.systemDateTime.localInstanceLastChangedAt: true
      //    local_last_changed_at as LocalLastChangedAt,
      //    @Semantics.systemDateTime.lastChangedAt: true
      //    last_changed_at       as LastChangedAt
}
