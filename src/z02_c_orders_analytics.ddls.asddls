@EndUserText.label: 'Orders Analytics'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE

define view entity Z02_C_ORDERS_ANALYTICS
  as select from Z02_I_ORDERS
{
  key OrderId,
      CustomerId,
      OrderDate,
      Status,
      MaterialId,

  @Semantics.amount.currencyCode: 'Currency'
      Amount,

      Currency
}
