
-- declare @LocNo varchar(5) = '00078'
drop table if exists #these
select distinct RptIt 
into #these
from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
where ie.PurchaseFromVendorID in ('TEXASBKMNB','TEXASSTATI','TEXASBKNON','TEXASBKPUZ','TEXASBKUPC','TEXASBKMNA')  --  
    -- and Rord = 'YY'
    and AvailWMS > 0

-- Postscript, tack-on additional crap-------------
---------------------------------------------------
declare @eDt date = datefromparts(datepart(YY,getdate()),datepart(MM,getdate()),1)
declare @sDt date = dateadd(MM,-1,@eDt)

drop table if exists #RptItLocTots
select ie.RptIt
    ,ng.Loc[LocNo]
    ,max(case when ng.Xacn <> 'Sale' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
    ,-sum(case when ng.Xacn in ('iSale','hSale') then ng.Qty else 0 end)[onlSldQ]
into #RptItLocTots
from ReportsView..ngXacns ng
	inner join ReportsView..ngXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt
where ng.Xacn in ('CDC','Drps')
    or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt)
group by ie.RptIt
    ,ng.Loc
  
drop table if exists #ItemTots
select ie.Item
    ,max(case when ng.Xacn in ('CDC','Drps') and ng.Loc <> '00001' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
    ,-sum(case when ng.Xacn in ('iSale','hSale') then ng.Qty else 0 end)[onlSldQ]
into #ItemTots
from ReportsView..ngXacns ng
	inner join ReportsView..ngXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt
where ng.Xacn in ('CDC','Drps','iSale','hSale')
    or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt)
group by ie.Item
  
drop table if exists #RptItTots
select ie.RptIt
    ,max(case when ng.Xacn in ('CDC','Drps') and ng.Loc <> '00001' then ng.Qty else 0 end)[maxShpQ]
    ,-sum(case when ng.Xacn = 'Sale' then ng.Qty else 0 end)[lmoSldQ]
    ,-sum(case when ng.Xacn in ('iSale','hSale') then ng.Qty else 0 end)[onlSldQ]
into #RptItTots
from ReportsView..ngXacns ng
	inner join ReportsView..ngXacns_Items ie with(nolock) on ng.ItemCode = ie.ItemCode
    inner join #these th on ie.RptIt = th.RptIt
where ng.Xacn in ('CDC','Drps','iSale','hSale')
    or (ng.Xacn = 'Sale' and ng.Date >= @sDt and ng.Date < @eDt)
group by ie.RptIt
---------------------------------------------------



-- ItemAvgs data
select ie.RptIt[ItemNo]
    ,ie.RptIt
    ,ie.avgRoS
    ,ie.avgPctNM
    ,ie.stdvRoS
    ,ie.PctLocsSld
    ,ie.ChPctNM
    ,ie.ChPctSld
    ,ie.avgRcvDt
    ,coalesce(it.maxShpQ,0)[maxShpQ]
    ,coalesce(it.lmoSldQ,0)[lmoSldQ]
    ,coalesce(it.onlSldQ,0)[onlSldQ]
from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
    inner join #these th on ie.RptIt = th.RptIt
    left join #RptItTots it on ie.ItemCode = it.RptIt 
group by ie.RptIt
    ,ie.avgRoS
    ,ie.avgPctNM
    ,ie.stdvRoS
    ,ie.PctLocsSld
    ,ie.ChPctNM
    ,ie.ChPctSld
    ,ie.avgRcvDt
    ,coalesce(it.maxShpQ,0)
    ,coalesce(it.lmoSldQ,0)
    ,coalesce(it.onlSldQ,0)
order by ie.RptIt


-- ItemEquivs data
select ie.PurchaseFromVendorID[pfVndr]
    ,ie.RptIt
    ,ie.Item
    ,ie.ItemCode
    ,Section
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
    ,pm.VendorID[OrigVndr]
    ,pm.ISBN
    ,pm.UPC
    ,coalesce(it.maxShpQ,0)[maxShpQ]
    ,coalesce(it.lmoSldQ,0)[lmoSldQ]
    ,coalesce(it.onlSldQ,0)[onlSldQ]
from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
    inner join #these th on ie.RptIt = th.RptIt
    left join #ItemTots it on ie.ItemCode = it.Item 
    inner join ReportsView..vw_DistributionProductMaster pm with(nolock)
        on ie.ItemCode = pm.ItemCode
order by RptIt
    ,ie.Item
    ,ie.ItemCode


-- SalesCS data
select bd.RptIt
    ,ie.PurchaseFromVendorID[pfVndr]
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
from ReportsView..SuggOrds_BaseData bd with(nolock)
    inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
        on bd.RptIt = ie.ItemCode
	inner join #these th on bd.RptIt = th.RptIt
order by bd.RptIt
    ,bd.Loc


-- ZID data
select bd.RptIt[ItemNo]
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
    ,coalesce(il.onlSldQ,0)[onlSldQ]
from ReportsView..SuggOrds_BaseData bd with(nolock)
    inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
        on bd.RptIt = ie.ItemCode
	inner join #these th on bd.RptIt = th.RptIt
    left join #RptItLocTots il on bd.RptIt = il.RptIt and bd.Loc = il.LocNo
order by bd.RptIt
    ,bd.Loc





