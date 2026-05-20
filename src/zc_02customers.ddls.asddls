@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'Z02CUSTOMERS'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_02CUSTOMERS
  provider contract transactional_query
  as projection on ZR_02CUSTOMERS
  association [1..1] to ZR_02CUSTOMERS as _BaseEntity on $projection.CustomerID = _BaseEntity.CustomerID
{
  key CustomerID,
  FirstName,
  LastName,
  PhoneNumber,
  Street,
  PostalCode,
  City,
  Country,
  Notes,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  Name,
  TotalOrders,
    @EndUserText.label: 'Revenue'
  @Semantics.amount.currencyCode: 'Currency'
  TotalRevenue,
  Currency,
    _BaseEntity,
  
    _Orders : redirected to composition child ZC_02ORDERS
}
