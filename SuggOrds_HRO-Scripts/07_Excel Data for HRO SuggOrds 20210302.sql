

-- SuggOrds data for all HRO Vendors---------------------
---------------------------------------------------------
-- Specific RptIts to be included from hro & ng SuggOrds...
drop table if exists #these
select distinct RptIt,Src,ie.PurchaseFromVendorID
into #these
from ReportsView..hroSuggOrds_ItemEquivs ie with(nolock)
where Rord <> 'NN'
    -- and ie.PurchaseFromVendorID in ('IDCROWNB&C','IDCROWNPOI')
    and ie.PurchaseFromVendorID in ('IDAURORA','IDBENDONPU','IDBKSALESI','IDBOOKDEPO','IDBRYBELLY','IDC&DVISIO'
    ,'IDCRAZART','IDCROWNB&C','IDCROWNPOI','IDCUDDLEBA','IDEUROGRA','IDFOUNDIMG','IDIGLOOBOO','IDKALANLPT'
    ,'IDKIKKERLA','IDLBMAYASS','IDMELISSA&','IDMODERNPU','IDNOSTIMAG','IDOUTOFPRI','IDPEEPERS','IDSALESCOR'
    ,'IDTOYSMITH','IDUNEMPLOY','IDUSPLAYIN','IDWISHPETS','IFDISCONFO','IFPROPERRE','IDMAKEITRE','IDGIANTMIC') 
    
-- select count(*) 
-- from ReportsView..hroSuggOrds_ItemEquivs ie with(nolock)
-- where Rord <> 'NN'
--     and ie.PurchaseFromVendorID in ('IDAURORA') 

-- Workbook Groupings--------------
drop table if exists #ExcelGrps
create table #ExcelGrps(Vendor varchar(10),ExcelGrp varchar(20))
insert into #ExcelGrps values ('IDBENDONPU','Kids'),('IDBKSALESI','BSI'),('IDBOOKDEPO','BSI'),('IDBRYBELLY','Kids')
    ,('IDC&DVISIO','StatiSides'),('IDCRAZART','Kids'),('IDCROWNB&C','CrownPoint'),('IDCROWNPOI','CrownPoint'),('IDCUDDLEBA','Kids')
    ,('IDEUROGRA','StatiSides'),('IDFOUNDIMG','StatiSides'),('IDIGLOOBOO','misc'),('IDKALANLPT','StatiSides'),('IDKIKKERLA','StatiSides')
    ,('IDLBMAYASS','misc'),('IDMELISSA&','Kids'),('IDMODERNPU','Kids'),('IDNOSTIMAG','StatiSides'),('IDOUTOFPRI','StatiSides')
    ,('IDPEEPERS','StatiSides'),('IDSALESCOR','misc'),('IDTOYSMITH','Kids'),('IDUNEMPLOY','StatiSides'),('IDUSPLAYIN','StatiSides')
    ,('IFDISCONFO','Media'),('IFPROPERRE','Media'),('IFWORDSWOR','misc'),('IDAURORA','Kids'),('IDWISHPETS','Kids'),('IDMAKEITRE','Kids'),('IDGIANTMIC','Kids')



-- Postscript, tack-on additional crap----------------------------
-- ...which is why data is pulled from both ngXacns AND hroXacns
------------------------------------------------------------------
declare @eDt date = datefromparts(datepart(YY,getdate()),datepart(MM,getdate()),1)
declare @sDt date = dateadd(MM,-1,@eDt)

drop table if exists #ItLocTots
select ie.RptIt
    ,ng.Loc[LocNo]
    ,max(case when ng.Xacn <> 'Sale' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
into #ItLocTots
from ReportsView..hroXacns ng
	inner join ReportsView..hroXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt --and th.Src = 'hro'
where (ng.Xacn in ('CDC','Drps')
        or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt))
group by ie.RptIt
    ,ng.Loc

insert into #ItLocTots
select ie.RptIt
    ,ng.Loc[LocNo]
    ,max(case when ng.Xacn <> 'Sale' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
from ReportsView..ngXacns ng
	inner join ReportsView..ngXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt --and th.Src = 'ng'
where (ng.Xacn in ('CDC','Drps')
        or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt))
    and ie.RptIt not in (select distinct RptIt from ReportsView..hroXacns_Items)
group by ie.RptIt
    ,ng.Loc

  
drop table if exists #ItTots
select ie.RptIt
    ,max(case when ng.Xacn in ('CDC','Drps') and ng.Loc <> '00001' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
    ,-sum(case when ng.Xacn in ('iSale','hSale') then ng.Qty else 0 end)[onlSldQ]
into #ItTots
from ReportsView..hroXacns ng
	inner join ReportsView..hroXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt --and th.Src = 'hro'
where (ng.Xacn in ('CDC','Drps','iSale','hSale')
        or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt))
group by ie.RptIt

insert into #ItTots
select ie.RptIt
    ,max(case when ng.Xacn in ('CDC','Drps') and ng.Loc <> '00001' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
    ,-sum(case when ng.Xacn in ('iSale','hSale') then ng.Qty else 0 end)[onlSldQ]
from ReportsView..ngXacns ng
	inner join ReportsView..ngXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt --and th.Src = 'ng'
where (ng.Xacn in ('CDC','Drps','iSale','hSale')
        or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt))
    and ie.RptIt not in (select distinct RptIt from ReportsView..hroXacns_Items)
group by ie.RptIt
---------------------------------------------------


-- From hroSuggOrds (which combines results from ngXacns & hroXacns)----
------------------------------------------------------------------------
-- SalesCS data
drop table if exists #SalesCS
select ie.Section
    ,bd.RptIt
    ,ltrim(rtrim(case when ie.PurchaseFromVendorID = '' then pm.VendorID 
          else ie.PurchaseFromVendorID end))[Vendor]
    ,Loc
    ,ShipQty
    ,netXfers
    ,SoldQty
    ,RtrnQty
    ,SoldVal
    ,''DiscVal
    ,''ListVal
    ,mdSoldQty
    ,MDSoldVal
    ,''MDDiscVal
    ,''MDListVal
    ,''ShpDt
    ,RcvDt
    ,minDt
    ,maxDt
    ,iStSQty
    ,oStSQty
    ,TshDntQty
    ,DmgQty
    ,DntQty
    ,BksQty
    ,MktQty
    ,VndQty
    ,ie.AvailWMS
	,cast(cast(bd.RptIt as bigint)as varchar(20)) 
		+ '-' + cast((1 * Loc)as varchar(20))[!!]
into #SalesCS
from ReportsView..hroSuggOrds_BaseData bd with(nolock)
    inner join ReportsView..hroSuggOrds_ItemEquivs ie with(nolock) on bd.RptIt = ie.ItemCode
    inner join ReportsView..vw_DistributionProductMaster pm with(nolock) on ie.RptIt = pm.ItemCode
	inner join #these th on bd.RptIt = th.RptIt 
order by bd.RptIt
    ,bd.Loc


-- ZID data
drop table if exists #ZIDs
select ie.Section
    ,ltrim(rtrim(case when ie.PurchaseFromVendorID = '' then pm.VendorID 
          else ie.PurchaseFromVendorID end))[Vendor]
    ,bd.RptIt[ItemNo]
    ,bd.RptIt
    ,Loc
    ,QtyInb
    ,SldXacns
    ,QtySld
    ,QtyMDSld
    ,TshDntQty
    ,minDt
    ,maxDt
    ,LGI
    ,TotInvDays
    ,RoS
    ,PctNM
    ,zRoS
    ,zPctNM
	,cast(cast(bd.RptIt as bigint)as varchar(20)) 
		+ '-' + cast((1 * Loc)as varchar(20))[ItNo-Loc]
    ,ie.AvailWMS
    ,ie.Rord
    ,coalesce(il.maxShpQ,0)[maxShpQ]
    ,coalesce(il.lmoSldQ,0)[lmoSldQ]
into #ZIDs
from ReportsView..hroSuggOrds_BaseData bd with(nolock)
    inner join ReportsView..hroSuggOrds_ItemEquivs ie with(nolock) on bd.RptIt = ie.ItemCode
    inner join ReportsView..vw_DistributionProductMaster pm with(nolock) on ie.RptIt = pm.ItemCode
	inner join #these th on bd.RptIt = th.RptIt 
    left join #ItLocTots il on bd.RptIt = il.RptIt and bd.Loc = il.LocNo
order by bd.RptIt
    ,bd.Loc


-- ItemAvgs data
drop table if exists #ItAvgs
select ie.Section
    ,ltrim(rtrim(case when ie.PurchaseFromVendorID = '' then pm.VendorID 
          else ie.PurchaseFromVendorID end))[Vendor]
    ,ie.RptIt[ItemNo]
    ,ie.RptIt
    ,coalesce(avgRoS,0)[avgRoS]
    ,coalesce(avgPctNM,0)[avgPctNM]
    ,coalesce(stdvRoS,0)[stdvRoS]
    ,coalesce(PctLocsSld,1)[PctLocsSld]
    ,coalesce(ChPctNM,0)[ChPctNM]
    ,coalesce(ChPctSld,0)[ChPctSld]
    ,avgRcvDt
into #ItAvgs
from ReportsView..hroSuggOrds_ItemEquivs ie with(nolock) 
    inner join ReportsView..vw_DistributionProductMaster pm with(nolock) on ie.RptIt = pm.ItemCode
	inner join #these th on ie.RptIt = th.RptIt 
where ie.ItemCode = ie.RptIt
group by ie.Section
    ,ltrim(rtrim(case when ie.PurchaseFromVendorID = '' then pm.VendorID 
          else ie.PurchaseFromVendorID end))
    ,ie.RptIt
    ,avgRoS
    ,avgPctNM
    ,stdvRoS
    ,PctLocsSld
    ,ChPctNM
    ,ChPctSld
    ,avgRcvDt
order by ie.RptIt


-- ItemEquivs data
drop table if exists #ItEquivs
select ltrim(rtrim(case when ie.PurchaseFromVendorID = '' then pm.VendorID 
          else ie.PurchaseFromVendorID end))[Vendor]
    ,ie.RptIt
    ,Item
    ,ie.ItemCode
    ,ie.Section
    ,Scheme
    ,PO
    ,ie.Title
    ,ie.Cost
    ,ie.Price
    ,Rord
    ,CaseQty
    ,AvailWMS
    ,ie.note
    ,ltrim(rtrim(pm.ProductType))[PrTy]
    -- ,pm.VendorID[OrigVndr]
    ,pm.VendorItemNo[VndrItemNo]
    ,pm.ISBN
    ,pm.UPC
    ,coalesce(it.maxShpQ,0)[maxShpQ]
    ,coalesce(it.lmoSldQ,0)[lmoSldQ]
    ,coalesce(it.onlSldQ,0)[onlSldQ]
into #ItEquivs
from ReportsView..hroSuggOrds_ItemEquivs ie with(nolock)
    inner join ReportsView..vw_DistributionProductMaster pm with(nolock) on ie.ItemCode = pm.ItemCode
	inner join #these th on ie.RptIt = th.RptIt 
    left join #ItTots it on ie.RptIt = it.RptIt 
order by RptIt
    ,Item
    ,ItemCode




-- CSV Output for Garren----------------------------------
----------------------------------------------------------


-- ALL Vendor ItAvgs & ItEquivs----------
select so.*
from #ItAvgs so --where so.Vendor = 'IDBOOKDEPO'
select so.*
from #ItEquivs so --where so.Vendor = 'IDBOOKDEPO'

-- ALL Vendors SalesCS & ZID-------------
select so.*
from #SalesCS so --where so.Vendor = 'IDBOOKDEPO'
order by so.Vendor,so.RptIt,so.Loc
select so.*
from #ZIDs so --where so.Vendor = 'IDBOOKDEPO'
order by so.Vendor,so.ItemNo,so.Loc


-- End of Month Vendor Item Totals-----------
drop table if exists #VendorParams
create table #VendorParams(Vendor varchar(20), OrdFreq int, BackoutDays int, DaysInvOrd int, RoundMethod int)
insert into #VendorParams values 
    ('IDAURORA',84,31,90,0),('IDBENDONPU',90,31,90,1),('IDBKSALESI',180,31,210,0),('IDBOOKDEPO',90,31,120,0),('IDBRYBELLY',84,31,90,0)
    ,('IDC&DVISIO',84,31,90,0),('IDCRAZART',84,31,90,1),('IDCROWNB&C',42,31,90,0),('IDCROWNPOI',42,31,90,0),('IDCUDDLEBA',126,31,150,0)
    ,('IDEUROGRA',42,31,60,0),('IDFOUNDIMG',126,31,150,0),('IDIGLOOBOO',90,31,120,0),('IDKALANLPT',84,31,90,0),('IDKIKKERLA',84,31,90,0)
    ,('IDLBMAYASS',126,31,150,0),('IDMELISSA&',84,31,90,0),('IDMODERNPU',84,31,90,0),('IDNOSTIMAG',84,31,90,0),('IDOUTOFPRI',84,31,90,0)
    ,('IDPEEPERS',84,31,90,0),('IDSALESCOR',84,31,90,0),('IDTOYSMITH',84,31,90,0),('IDUNEMPLOY',84,31,90,0),('IDUSPLAYIN',84,31,90,0)
    ,('IDWISHPETS',84,31,90,0),('IFDISCONFO',180,60,210,0),('IFPROPERRE',180,60,210,0),('IDMAKEITRE',84,31,90,0),('IDGIANTMIC',84,31,90,0)

select g.ExcelGrp
    ,g.Vendor
    ,e.Item
    ,e.ItemCode
    ,e.Title
    ,right(e.Rord,1)[RO?]
    ,e.Section
    ,e.PrTy
    ,d.QOH
    ,e.Cost
    ,e.Price
    ,d.NumLocs
    ,d.PrjOrd
    ,d.TotalShipQ
    ,d.TotalSoldQ
    ,e.lmoSldQ[PastMoSoldQ]
    ,e.VndrItemNo
    ,e.ISBN
    ,e.UPC
    ,a.avgRoS
from #ItEquivs e 
    inner join #ExcelGrps g on g.Vendor = e.Vendor
    inner join #ItAvgs a on a.RptIt = e.RptIt
    inner join(
            select b.RptIt,sum(LGI)[QOH]
                ,count(distinct case when LGI > 0 then Loc end)[NumLocs]
                ,sum(ShipQty)[TotalShipQ]
                ,sum(QtySld)[TotalSoldQ]
                ,sum(case when p.RoundMethod = 1
                        then ceiling(case when RoS * DaysInvOrd < (case when LGI < RoS * p.BackoutDays then 0 else LGI - RoS * p.BackoutDays end) then 0
                                          else RoS * DaysInvOrd - (case when LGI < RoS * p.BackoutDays then 0 else LGI - RoS * p.BackoutDays end) end)
                        else   round(case when RoS * DaysInvOrd < (case when LGI < RoS * p.BackoutDays then 0 else LGI - RoS * p.BackoutDays end) then 0
                                          else RoS * DaysInvOrd - (case when LGI < RoS * p.BackoutDays then 0 else LGI - RoS * p.BackoutDays end) end,0) end)PrjOrd
            from ReportsView..hroSuggOrds_BaseData b 
                inner join ReportsView..hroSuggOrds_ItemEquivs e on e.ItemCode = b.RptIt
                inner join #VendorParams p on p.Vendor = e.PurchaseFromVendorID
            group by b.RptIt
        )d on d.RptIt = e.RptIt
where e.ItemCode = e.RptIt
    and e.ItemCode < '00000000000100000000'
order by ExcelGrp,Vendor,ItemCode

-- 7386 unique items as of 1/3/22


