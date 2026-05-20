@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for z02orders'
@Metadata.ignorePropagatedAnnotations: false
define view entity ZR_02ORDES as select from z02orders
//composition of target_data_source_name as _association_name
    association        to parent ZR_02CUSTOMERS as _Customers on $projection.CustomerId = _Customers.CustomerID
    association [1..1] to Z02_I_MATERIALS   as _Materials on $projection.MaterialId = _Materials.MaterialId 
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
    _Materials,
    _Status
 //   _association_name // Make association public
}
