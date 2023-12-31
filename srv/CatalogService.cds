using { priya.db } from '../db/datamodel';
using { priya.cds } from '../db/CDSViews';
service CatalogService @(path : 'CatalogService') {
    //@Capabilities.Insertable
    entity BusinessPartnerSet as projection on db.master.businesspartner;
    entity AddressSet as projection on db.master.address;
    //@readonly
    entity EmployeeSet as projection on db.master.employees {
        ID,
        nameFirst,
        nameLast,
        sex,
        phoneNumber,
        email
    };
 
    entity PurchaseOrder @(
        odata.draft.enabled: true
    ) as projection on db.transaction.purchaseorder{
        *,
        case OVERALL_STATUS
            when 'N' then 'New'
            when 'P' then 'Paid'
            when 'B' then 'Blocked'
            else 'Delivered' end as OVERALL_STATUS: String(20),
        case OVERALL_STATUS
            when 'N' then 0
            when 'P' then 1
            when 'B' then 2
            else 3 end as Criticality: Integer
    }
    actions{
        @cds.odata.bindingparameter.name : '_priya'
        @Common.SideEffects : {
                TargetProperties : ['_priya/GROSS_AMOUNT']
            }  
        action boost() returns PurchaseOrder;
        @cds.odata.bindingparameter.name : '_ananya'
        @Common.SideEffects : {
                TargetProperties : ['_ananya/OVERALL_STATUS']
            }  
        action setOrderProcessing();
        function largestOrder() returns array of PurchaseOrder;
    };
    // entity PurchaseOrder as projection on db.transaction.purchaseorder;
    function getOrderDefaults() returns PurchaseOrder;
    entity PurchaseOrderItems as projection on db.transaction.poitems;
    entity ProductSet as projection on cds.CDSViews.ProductView;
    // entity PurchaseOrderSet as projection on cds.CDSViews.POWorklist;
    // entity ItemView as projection on cds.CDSViews.ItemView;
    // entity ProductView as projection on cds.CDSViews.ProductView;
    // entity ProductSales as projection on cds.CDSViews.CProductValuesView;
}