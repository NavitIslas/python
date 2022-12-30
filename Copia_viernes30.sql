(SELECT s.account_obj_id0
FROM data_staging.brm_account_t AS a
JOIN data_staging.brm_service_t AS s
ON a.poid_id0=s.account_obj_id0
WHERE split_part(a.gl_segment,'.',2)='4'
      AND s.info_day=20221227)


SELECT *
FROM data_staging.brm_account_t AS a
JOIN data_staging.brm_service_t AS s
ON a.poid_id0=s.account_obj_id0
WHERE split_part(a.gl_segment,'.',2)='4'
      AND s.info_day=20221227
      AND s.account_obj_id0=180472910964;


--CUENTA ESTATUS TIPO DE ONT
Select account_obj_id0, count(*),status, poid_id0, POID_TYPE
from data_staging.brm_service_t
where info_day=20221227
      and account_obj_id0=180472910964
      and account_obj_id0 in (SELECT s.account_obj_id0
                               FROM data_staging.brm_account_t AS a
                               JOIN data_staging.brm_service_t AS s
                               ON a.poid_id0=s.account_obj_id0
                               WHERE split_part(a.gl_segment,'.',2)='4'
                               AND s.info_day=20221227)
group by account_obj_id0,status, poid_id0, POID_TYPE
--HAVING  count(account_obj_id0) > 1
limit 100;

--CUENTA ESTATUS TIPO DE ONT
SELECT account_obj_id0, SUM(tvs_activas) AS num_tvs_activas, SUM(tels_activos) AS num_tels_activos, SUM(modems_activos) AS num_modems_activos,
       SUM(tvs_inactivas) AS num_tvs_inactivas, SUM(tels_inactivos) AS num_tels_inactivos, SUM(modems_inactivos) AS num_modems_inactivos,
       SUM(tvs_activas) + SUM(tvs_inactivas) AS historico_tvs, SUM(tels_activos) + SUM(tels_inactivos) AS historico_tels,
       SUM(modems_activos) + SUM(modems_inactivos) AS historico_modems
FROM(SELECT account_obj_id0, 
            CASE WHEN status=10100 AND poid_type='/service/totalplay/tv' THEN 1
                 ELSE 0
            END AS tvs_activas,
            CASE WHEN status=10100 AND poid_type='/service/totalplay/telephony' THEN 1
                 ELSE 0      
            END AS tels_activos,
            CASE WHEN status=10100 AND poid_type='/service/totalplay/ip' THEN 1
                 ELSE 0
            END AS modems_activos,
            CASE WHEN status=10103 AND poid_type='/service/totalplay/tv' THEN 1
                 ELSE 0
            END AS tvs_inactivas,
            CASE WHEN status=10103 AND poid_type='/service/totalplay/telephony' THEN 1
                 ELSE 0
            END AS tels_inactivos,
            CASE WHEN status=10103 AND poid_type='/service/totalplay/ip' THEN 1
                 ELSE 0
            END AS modems_inactivos
    FROM data_staging.brm_service_t
    WHERE info_day=20221227
          AND account_obj_id0 in(180472910964,12180022932)
          AND account_obj_id0 IN (SELECT s.account_obj_id0
                                  FROM data_staging.brm_account_t AS a
                                  JOIN data_staging.brm_service_t AS s
                                  ON a.poid_id0=s.account_obj_id0
                                  WHERE split_part(a.gl_segment,'.',2)='4'
                                        AND s.info_day=20221227)
    GROUP BY account_obj_id0,status, poid_id0, POID_TYPE)
GROUP BY account_obj_id0
limit 100;

select *
from staging_layer.brm_purchased_product_t
where info_day = 20221130
      AND account_obj_id0=180472910964
LIMIT 100;


SELECT s.account_obj_id0, s.status, s.poid_id0, s.poid_type,
       pp.service_obj_id0, pp.descr, pp.service_obj_type, pp.cycle_fee_amt, pp.quantity
FROM(SELECT account_obj_id0,status, poid_id0, poid_type
     FROM data_staging.brm_service_t
     WHERE info_day=20221227
           AND account_obj_id0=180472910964) AS s
JOIN(SELECT account_obj_id0, service_obj_id0, descr, service_obj_type, cycle_fee_amt, quantity
           FROM staging_layer.brm_purchased_product_t
           WHERE info_day = 20221130
           AND account_obj_id0=180472910964) AS pp
ON pp.account_obj_id0 = s.account_obj_id0 AND pp.service_obj_id0 = s.poid_id0
limit 100;

select *
from staging_layer.brm_purchased_product_t
where info_day = 20221130
      AND account_obj_id0=180472910964
LIMIT 100;

SELECT ROUND(SUM(DECODE(pp.status_flags,0, rbi.scaled_amount 
                ,8, rbi.scaled_amount 
                ,1, rbi.scaled_amount 
                ,4, rbi.scaled_amount 
                ,9, rbi.scaled_amount 
                ,12, rbi.scaled_amount 
                ,DECODE(pp.status_flags ,33554432,CYCLE_FEE_AMT 
                      ,33554433,CYCLE_FEE_AMT 
                      ,33554440,CYCLE_FEE_AMT 
                      ,33554441,CYCLE_FEE_AMT 
                      ,50331648,CYCLE_FEE_AMT 
                      ,50331648,CYCLE_FEE_AMT 
                      , purchase_fee_amt))),0)  precio 
FROM  (SELECT *
       FROM data_staging.brm_account_t 
       WHERE info_day=20221226
            AND account_no=0114285640
       ) AS a1
      JOIN (SELECT *
            FROM data_staging.brm_service_t 
            )AS s
      ON s.account_obj_id0= a1.poid_id0 
      JOIN (SELECT *
            FROM data_staging.brm_purchased_product_t 
            WHERE price_list_name IN ('0') 
                  AND status!=3
            )AS pp
      ON pp.service_obj_id0 = s.poid_id0  AND pp.account_obj_id0=s.account_obj_id0 
      JOIN (SELECT *
            FROM data_staging.brm_product_t 
            )AS p
      ON p.poid_id0= pp.product_obj_id0 
      JOIN (SELECT *
            FROM data_staging.brm_Rate_Plan_T 
            )AS rp
      ON rp.Product_Obj_Id0= p.poid_id0 
      JOIN (SELECT *
            FROM data_staging.brm_Rate_Bal_Impacts_T 
            WHERE element_id =484 
            )AS rbi
      ON rbi.Obj_Id0= r.Poid_Id0 
      JOIN (SELECT *
            FROM data_staging.brm_Rate_T 
           )AS r
      ON r.Rate_Plan_Obj_Id0=rp.Poid_Id0; 

             

SELECT *
FROM data_staging.brm_account_t AS a1
      JOIN data_staging.brm_service_t AS s
      ON s.account_obj_id0= a1.poid_id0 
WHERE s.info_day=20221227
           AND s.account_obj_id0=180472910964;
           
SELECT *
            FROM data_staging.brm_purchased_product_t 
            WHERE price_list_name IN ('0') 
                  AND status!=3
LIMIT 100;
