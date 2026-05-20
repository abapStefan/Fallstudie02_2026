@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Orders'
@Metadata.ignorePropagatedAnnotations: false
define view entity Z02_I_ORDERS 
    as select from z02orders 
    association        to parent ZR_02CUSTOMERS as _Customers on $projection.CustomerId = _Customers.CustomerID
    association [1..1] to Z02_I_STATUS   as _Status on $projection.Status = _Status.Status  
{
    key order_id as OrderId,
    customer_id as CustomerId,
    material_id as MaterialId,
    quantity as Quantity,
    order_date as OrderDate,
    amount as Amount,
    currency as Currency,
    status as Status,
    created_by as CreatedBy,
    created_at as CreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    _Customers,
    _Status
}
