DROP FUNCTION IF EXISTS copyso(integer, date);

CREATE OR REPLACE FUNCTION copyso(psoheadid integer, pcustomer integer, pscheddate date)
  RETURNS integer AS
$BODY$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _soheadid INTEGER;
  _soitemid INTEGER;
  _soitem RECORD;
  _newCustomer BOOLEAN;
  _customer RECORD;

BEGIN

  SELECT NEXTVAL('cohead_cohead_id_seq') INTO _soheadid;

-- Check whether we are copying to a new customer
  SELECT (cohead_cust_id <> COALESCE(pCustomer, cohead_cust_id)) INTO _newCustomer
    FROM cohead
    WHERE cohead_id = pSoheadid;

  IF (NOT _newCustomer) THEN

  INSERT INTO cohead
  ( cohead_id,
    cohead_number,
    cohead_cust_id,
    cohead_custponumber,
    cohead_type,
    cohead_orderdate,
    cohead_warehous_id,
    cohead_shipto_id,
    cohead_shiptoname,
    cohead_shiptoaddress1,
    cohead_shiptoaddress2,
    cohead_shiptoaddress3,
    cohead_shiptoaddress4,
    cohead_shiptoaddress5,
    cohead_salesrep_id,
    cohead_terms_id,
    cohead_fob,
    cohead_shipvia,
    cohead_shiptocity,
    cohead_shiptostate,
    cohead_shiptozipcode,
    cohead_freight,
    cohead_misc,
    cohead_imported,
    cohead_ordercomments,
    cohead_shipcomments,
    cohead_shiptophone,
    cohead_shipchrg_id,
    cohead_shipform_id,
    cohead_billtoname,
    cohead_billtoaddress1,
    cohead_billtoaddress2,
    cohead_billtoaddress3,
    cohead_billtocity,
    cohead_billtostate,
    cohead_billtozipcode,
    cohead_misc_accnt_id,
    cohead_misc_descrip,
    cohead_commission,
    cohead_miscdate,
    cohead_holdtype,
    cohead_packdate,
    cohead_prj_id,
    cohead_wasquote,
    cohead_lastupdated,
    cohead_shipcomplete,
    cohead_created,
    cohead_creator,
    cohead_quote_number,
    cohead_billtocountry,
    cohead_shiptocountry,
    cohead_curr_id,
    cohead_calcfreight,
    cohead_shipto_cntct_id,
    cohead_shipto_cntct_honorific,
    cohead_shipto_cntct_first_name,
    cohead_shipto_cntct_middle,
    cohead_shipto_cntct_last_name,
    cohead_shipto_cntct_suffix,
    cohead_shipto_cntct_phone,
    cohead_shipto_cntct_title,
    cohead_shipto_cntct_fax,
    cohead_shipto_cntct_email,
    cohead_billto_cntct_id,
    cohead_billto_cntct_honorific,
    cohead_billto_cntct_first_name,
    cohead_billto_cntct_middle,
    cohead_billto_cntct_last_name,
    cohead_billto_cntct_suffix,
    cohead_billto_cntct_phone,
    cohead_billto_cntct_title,
    cohead_billto_cntct_fax,
    cohead_billto_cntct_email,
    cohead_taxzone_id,
    cohead_taxtype_id,
    cohead_ophead_id,
    cohead_status,
    cohead_saletype_id,
    cohead_shipzone_id )
  SELECT
    _soheadid,
    fetchSoNumber(),
    cohead_cust_id,
    cohead_custponumber,
    cohead_type,
    CURRENT_DATE,
    cohead_warehous_id,
    cohead_shipto_id,
    cohead_shiptoname,
    cohead_shiptoaddress1,
    cohead_shiptoaddress2,
    cohead_shiptoaddress3,
    cohead_shiptoaddress4,
    cohead_shiptoaddress5,
    cohead_salesrep_id,
    cohead_terms_id,
    cohead_fob,
    cohead_shipvia,
    cohead_shiptocity,
    cohead_shiptostate,
    cohead_shiptozipcode,
    cohead_freight,
    cohead_misc,
    FALSE,
    cohead_ordercomments,
    cohead_shipcomments,
    cohead_shiptophone,
    cohead_shipchrg_id,
    cohead_shipform_id,
    cohead_billtoname,
    cohead_billtoaddress1,
    cohead_billtoaddress2,
    cohead_billtoaddress3,
    cohead_billtocity,
    cohead_billtostate,
    cohead_billtozipcode,
    cohead_misc_accnt_id,
    cohead_misc_descrip,
    cohead_commission,
    cohead_miscdate,
    cohead_holdtype,
    COALESCE(pSchedDate, cohead_packdate),
    cohead_prj_id,
    FALSE,
    cohead_lastupdated,
    cohead_shipcomplete,
    NULL,
    getEffectiveXtUser(),
    NULL,
    cohead_billtocountry,
    cohead_shiptocountry,
    cohead_curr_id,
    cohead_calcfreight,
    cohead_shipto_cntct_id,
    cohead_shipto_cntct_honorific,
    cohead_shipto_cntct_first_name,
    cohead_shipto_cntct_middle,
    cohead_shipto_cntct_last_name,
    cohead_shipto_cntct_suffix,
    cohead_shipto_cntct_phone,
    cohead_shipto_cntct_title,
    cohead_shipto_cntct_fax,
    cohead_shipto_cntct_email,
    cohead_billto_cntct_id,
    cohead_billto_cntct_honorific,
    cohead_billto_cntct_first_name,
    cohead_billto_cntct_middle,
    cohead_billto_cntct_last_name,
    cohead_billto_cntct_suffix,
    cohead_billto_cntct_phone,
    cohead_billto_cntct_title,
    cohead_billto_cntct_fax,
    cohead_billto_cntct_email,
    cohead_taxzone_id,
    cohead_taxtype_id,
    cohead_ophead_id,
    cohead_status,
    cohead_saletype_id,
    cohead_shipzone_id
  FROM cohead
  WHERE (cohead_id=pSoheadid);

  ELSE -- Copy SO to New Customer 
    -- Get Customer details
    SELECT cust_id, cust_name, cust_salesrep_id, cust_terms_id, cust_shipvia, cust_shipchrg_id,
      cust_shipform_id, cust_commprcnt, cust_partialship, cust_taxzone_id, cust_curr_id,
      bc.cntct_id AS billing_contact_id, bc.cntct_honorific AS billing_honorific, bc.cntct_first_name AS billing_first_name, bc.cntct_middle AS billing_middle, bc.cntct_last_name AS billing_last_name,
      bc.cntct_suffix AS billing_suffix, bc.cntct_phone AS billing_phone, bc.cntct_title AS billing_title, bc.cntct_fax AS billing_fax, bc.cntct_email AS billing_email,
      ba.addr_line1 AS billing1, ba.addr_line2 AS billing2, ba.addr_line3 AS billing3, ba.addr_city AS billing_city, ba.addr_state AS billing_state, ba.addr_postalcode AS billing_postalcode, ba.addr_country AS billing_country,
      shipto_id, shipto_name, sc.cntct_id AS shipto_contact_id, sc.cntct_honorific AS shipto_honorific, sc.cntct_phone AS shipto_phone, sc.cntct_first_name AS shipto_first_name, sc.cntct_middle AS shipto_middle, sc.cntct_last_name AS shipto_last_name,
      sc.cntct_suffix AS shipto_suffix, sc.cntct_phone AS shipto_phone, sc.cntct_title AS shipto_title, sc.cntct_fax AS shipto_fax, sc.cntct_email AS shipto_email,
      sa.addr_line1 AS shipto1, sa.addr_line2 AS shipto2, sa.addr_line3 AS shipto3, sa.addr_city AS shipto_city, sa.addr_state AS shipto_state, sa.addr_postalcode AS shipto_postalcode, sa.addr_country AS shipto_country
    INTO _customer  
    FROM custinfo 
    LEFT OUTER join cntct bc ON (cust_cntct_id=bc.cntct_id)
    LEFT OUTER JOIN addr ba ON (cntct_addr_id=ba.addr_id)
    LEFT OUTER JOIN shiptoinfo ON ((shipto_cust_id=cust_id)
                                         AND (shipto_default)) 
    LEFT OUTER join cntct sc ON (shipto_cntct_id=sc.cntct_id)
    LEFT OUTER JOIN addr sa ON (shipto_addr_id=sa.addr_id)                                         
    WHERE cust_id=pCustomer;

  INSERT INTO cohead
  ( cohead_id,
    cohead_number,
    cohead_cust_id,
    cohead_custponumber,
    cohead_type,
    cohead_orderdate,
    cohead_warehous_id,
    cohead_shipto_id,
    cohead_shiptoname,
    cohead_shiptoaddress1,
    cohead_shiptoaddress2,
    cohead_shiptoaddress3,
    cohead_salesrep_id,
    cohead_terms_id,
    cohead_fob,
    cohead_shipvia,
    cohead_shiptocity,
    cohead_shiptostate,
    cohead_shiptozipcode,
    cohead_freight,
    cohead_misc,
    cohead_imported,
    cohead_ordercomments,
    cohead_shipcomments,
    cohead_shiptophone,
    cohead_shipchrg_id,
    cohead_shipform_id,
    cohead_billtoname,
    cohead_billtoaddress1,
    cohead_billtoaddress2,
    cohead_billtoaddress3,
    cohead_billtocity,
    cohead_billtostate,
    cohead_billtozipcode,
    cohead_misc_accnt_id,
    cohead_misc_descrip,
    cohead_commission,
    cohead_miscdate,
    cohead_holdtype,
    cohead_packdate,
    cohead_prj_id,
    cohead_wasquote,
    cohead_lastupdated,
    cohead_shipcomplete,
    cohead_created,
    cohead_creator,
    cohead_quote_number,
    cohead_billtocountry,
    cohead_shiptocountry,
    cohead_curr_id,
    cohead_calcfreight,
    cohead_shipto_cntct_id,
    cohead_shipto_cntct_honorific,
    cohead_shipto_cntct_first_name,
    cohead_shipto_cntct_middle,
    cohead_shipto_cntct_last_name,
    cohead_shipto_cntct_suffix,
    cohead_shipto_cntct_phone,
    cohead_shipto_cntct_title,
    cohead_shipto_cntct_fax,
    cohead_shipto_cntct_email,
    cohead_billto_cntct_id,
    cohead_billto_cntct_honorific,
    cohead_billto_cntct_first_name,
    cohead_billto_cntct_middle,
    cohead_billto_cntct_last_name,
    cohead_billto_cntct_suffix,
    cohead_billto_cntct_phone,
    cohead_billto_cntct_title,
    cohead_billto_cntct_fax,
    cohead_billto_cntct_email,
    cohead_taxzone_id,
    cohead_taxtype_id,
    cohead_ophead_id,
    cohead_status,
    cohead_saletype_id,
    cohead_shipzone_id )
   SELECT
    _soheadid,
    fetchSoNumber(),
    pCustomer,
    '',
    cohead_type,
    CURRENT_DATE,
    cohead_warehous_id,
    COALESCE(_customer.shipto_id, NULL),
    _customer.shipto_name,
    _customer.shipto1,
    _customer.shipto2,
    _customer.shipto3,  
    _customer.cust_salesrep_id,
    _customer.cust_terms_id,
    cohead_fob,
    _customer.cust_shipvia,
    _customer.shipto_city,
    _customer.shipto_state,
    _customer.shipto_postalcode,
    cohead_freight,
    cohead_misc,
    FALSE,
    cohead_ordercomments,
    cohead_shipcomments,
    _customer.shipto_phone,
    _customer.cust_shipchrg_id,
    _customer.cust_shipform_id,
    _customer.cust_name,
    _customer.billing1,
    _customer.billing2,
    _customer.billing3,
    _customer.billing_city,
    _customer.billing_state,
    _customer.billing_postalcode,
    cohead_misc_accnt_id,
    cohead_misc_descrip,
    _customer.cust_commprcnt,
    cohead_miscdate,
    cohead_holdtype,
    COALESCE(pSchedDate, cohead_packdate),
    NULL, --cohead_prj_id,
    FALSE,
    CURRENT_DATE,
    _customer.cust_partialship,
    NULL,
    getEffectiveXtUser(),
    NULL,
    _customer.billing_country,
    _customer.shipto_country,
    _customer.cust_curr_id,
    cohead_calcfreight,
    _customer.shipto_contact_id,
    _customer.shipto_honorific,
    _customer.shipto_first_name,
    _customer.shipto_middle,
    _customer.shipto_last_name,
    _customer.shipto_suffix,
    _customer.shipto_phone,
    _customer.shipto_title,
    _customer.shipto_fax,
    _customer.shipto_email,    
    _customer.billing_contact_id,
    _customer.billing_honorific,
    _customer.billing_first_name,
    _customer.billing_middle,
    _customer.billing_last_name,
    _customer.billing_suffix,
    _customer.billing_phone,
    _customer.billing_title,
    _customer.billing_fax,
    _customer.billing_email,
    _customer.cust_taxzone_id,
    cohead_taxtype_id,
    cohead_ophead_id,
    'O',
    cohead_saletype_id,
    cohead_shipzone_id
  FROM cohead
  WHERE (cohead_id=pSoheadid);

  END IF;  -- Order Header population

  INSERT INTO charass
        (charass_target_type, charass_target_id,
         charass_char_id, charass_value)
  SELECT charass_target_type, _soheadid,
         charass_char_id, charass_value
    FROM charass
   WHERE ((charass_target_type='SO')
     AND  (charass_target_id=pSoheadid));

  FOR _soitem IN
    SELECT *
    FROM coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
    WHERE ( (coitem_cohead_id=pSoheadid)
      AND   (coitem_status <> 'X')
      AND   (coitem_subnumber = 0) ) LOOP

    SELECT NEXTVAL('coitem_coitem_id_seq') INTO _soitemid;

    -- insert characteristics first so they can be copied to associated supply order
    INSERT INTO charass
          (charass_target_type, charass_target_id,
           charass_char_id, charass_value)
    SELECT charass_target_type, _soitemid,
           charass_char_id, charass_value
      FROM charass
     WHERE ((charass_target_type='SI')
       AND  (charass_target_id=_soitem.coitem_id));

    INSERT INTO coitem
    ( coitem_id,
      coitem_cohead_id,
      coitem_linenumber,
      coitem_itemsite_id,
      coitem_status,
      coitem_scheddate,
      coitem_promdate,
      coitem_qtyord,
      coitem_unitcost,
      coitem_price,
      coitem_custprice,
      coitem_qtyshipped,
      coitem_order_id,
      coitem_memo,
      coitem_imported,
      coitem_qtyreturned,
      coitem_closedate,
      coitem_custpn,
      coitem_order_type,
      coitem_close_username,
--      coitem_lastupdated,
      coitem_substitute_item_id,
      coitem_created,
      coitem_creator,
      coitem_prcost,
      coitem_qty_uom_id,
      coitem_qty_invuomratio,
      coitem_price_uom_id,
      coitem_price_invuomratio,
      coitem_warranty,
      coitem_cos_accnt_id,
      coitem_qtyreserved,
      coitem_subnumber,
      coitem_firm,
      coitem_taxtype_id )
    VALUES
    ( _soitemid,
      _soheadid,
      _soitem.coitem_linenumber,
      _soitem.coitem_itemsite_id,
      'O',
      COALESCE(pSchedDate, _soitem.coitem_scheddate),
      _soitem.coitem_promdate,
      _soitem.coitem_qtyord,
      CASE WHEN fetchMetricBool('WholesalePriceCosting') THEN (SELECT item_listcost FROM item
                                                               WHERE item_id=_soitem.itemsite_item_id)
           ELSE stdCost(_soitem.itemsite_item_id)
      END,
      _soitem.coitem_price,
      _soitem.coitem_custprice,
      0.0,
      -1,
      _soitem.coitem_memo,
      FALSE,
      0.0,
      NULL,
      _soitem.coitem_custpn,
      _soitem.coitem_order_type,
      NULL,
--      NULL,
      _soitem.coitem_substitute_item_id,
      NULL,
      getEffectiveXtUser(),
      _soitem.coitem_prcost,
      _soitem.coitem_qty_uom_id,
      _soitem.coitem_qty_invuomratio,
      _soitem.coitem_price_uom_id,
      _soitem.coitem_price_invuomratio,
      _soitem.coitem_warranty,
      _soitem.coitem_cos_accnt_id,
      0.0,
      _soitem.coitem_subnumber,
      _soitem.coitem_firm,
      _soitem.coitem_taxtype_id );

  END LOOP;

  RETURN _soheadid;

END;
$BODY$
  LANGUAGE plpgsql;
