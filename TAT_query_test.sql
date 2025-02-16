SELECT   we.wip_entity_id, we.wip_entity_name, wdj.status_type,wdj.attribute2,
         msib.segment1 item_name, msib.inventory_item_id, wdj.creation_date,
         TO_CHAR (wdj.date_released, 'DD-MON-YYYY hh24:mi') date_released,
         wdj.date_released, wdj.date_closed,
         TO_CHAR (wdj.date_completed, 'DD-MON-YYYY hh24:mi') date_completed,
         wdj.start_quantity, wdj.quantity_completed
    FROM apps.wip_entities we,
         apps.wip_discrete_jobs wdj,
         apps.mtl_system_items_b msib
   WHERE we.wip_entity_id = wdj.wip_entity_id
     AND wdj.organization_id = msib.organization_id
     AND wdj.primary_item_id = msib.inventory_item_id
     AND EXISTS (
            SELECT bso.standard_operation_id
              FROM apps.bom_standard_operations bso, apps.wip_operations wo
             WHERE bso.organization_id = wo.organization_id
               AND bso.standard_operation_id = wo.standard_operation_id
               AND wo.wip_entity_id = wdj.wip_entity_id
               AND wo.organization_id = wdj.organization_id
               and bso.standard_operation_id in (select standard_operation_id from 
                apps.bom_standard_operations where operation_code in ('APP','PTH','PIC') and organization_id = 123))
              -- &P_OPER_LEXICAL)
     --AND wdj.status_type = 12
AND (   wdj.status_type IN (3) OR wdj.status_type IN (4) 
          OR (wdj.status_type IN (12) AND wdj.date_completed IS NOT NULL)
         )
     AND wdj.date_released BETWEEN :from_date AND :TO_DATE
     --AND wdj.date_completed IS NOT NULL
     --and wdj.attribute2 = :pmeter
     --and msib.segment1 = :item
     and we.wip_entity_name = :jobno
      and wdj.attribute2 is not null
     and wdj.attribute2 not in ('na','NA','n/a','N/A')
GROUP BY we.wip_entity_id,
         we.wip_entity_name,
         wdj.status_type,
         wdj.attribute2,
         msib.segment1,
         msib.inventory_item_id,
         wdj.creation_date,
         TO_CHAR (wdj.date_released, 'DD-MON-YYYY hh24:mi'),
         wdj.date_released,
         wdj.date_closed,
         TO_CHAR (wdj.date_completed, 'DD-MON-YYYY hh24:mi'),
         wdj.start_quantity,
         wdj.quantity_completed
ORDER BY 8 ASC





select * from component_traceability_details