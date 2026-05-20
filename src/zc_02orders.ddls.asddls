@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Orders'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZC_02ORDERS as projection on ZR_02ORDES
{
    key OrderId,
    CustomerId,
    MaterialId,
    Quantity,
    OrderDate,
    Amount,
    Currency,
    Status,
    CreatedBy,
    CreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Customers : redirected to parent ZC_02CUSTOMERS,
    _Materials,
    _Status
}
