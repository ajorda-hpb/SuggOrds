--Uses hroXacns data to calculate inventory levels for TTB Suggested Orders
--Lightly modified version of hroSuggOrdsTTB_ZID query, just to get it using hroXacns data
-------------------------------------------------------------------
--10/11/19: Version 1.0, just replacing data source to now use hroXacns.
----Ran diff tests to see where data differences came from. Everything seems fine.
----TODO: Need to think about if/how online sales should impact store rates of sale
----They definitely need to factor into inventory levels, but online stuff seems to
----be only tangentially attributable to one given store. Might be better to disperse
----online sales equally across ALL stores, assuming most/all stores do list their distro.
-------------------------------------------------------------------
--10/31/19: Happy Halloween! Added Title & Reorder info to the multiple reorderables warning query
-------------------------------------------------------------------
--3/5/20: Added logic on hroXacns extract to #xacns to exclude closed stores 20 & 106.
----Added the stdev of the RoS to the item summaries table that goes into the ZID spreadsheet.
-------------------------------------------------------------------
-- 12/2/2020: Couple more stores excluded due to closing: 11 & 52.
---- Modified refs to SetAdjs & Ages to include Item in the join, since it's now part of the PK.
-------------------------------------------------------------------
-- 6/28/21: Commented out references to the hroXacns_Ages table since the reported data doesn't include inventory age.
-------------------------------------------------------------------
-- 12/07/21: Added store 056 to list of excluded stores cos they're closing :(


--For HRO Suggested Orders, since these run so infrequently, just assuming that
-- everything that should be received has been received.
declare @eDate datetime
set @eDate = dateadd(DD,-1,getdate())


----CDC WMS Inventory limits to items with inventory-------
drop table if exists #icInv
;with wmsInv as(
    select right('00000000000000000000'+li.Item,20) collate database_default [ItemCode]
        ,li.Company collate database_default [Cmp]
        ,sum(li.ON_HAND_QTY + li.IN_TRANSIT_QTY - li.SUSPENSE_QTY - li.ALLOCATED_QTY)[InvQty]
    from WMS_ILS..LOCATION_INVENTORY li with(nolock)
    where li.COMPANY <> 'SUP'
    group by right('00000000000000000000'+li.Item,20)
        ,li.Company collate database_default
    having sum(li.ON_HAND_QTY + li.IN_TRANSIT_QTY - li.SUSPENSE_QTY - li.ALLOCATED_QTY) > 0
    )
select it.ItemCode
    ,it.RptIt
    ,sum(isnull(wi.InvQty,0))[InvQ]
into #icInv
from ReportsView..hroXacns_Items it inner join wmsInv wi 
    on wi.ItemCode = it.ItemCode
group by it.ItemCode
    ,it.RptIt


-- Limit Rollup data to just the items that have ever been reorderable...
drop table if exists #ActiveRptIts
select distinct RptIt
into #ActiveRptIts
from ReportsView..hroXacns_Items sb with(nolock)
	inner join ReportsView..vw_DistributionProductMaster pm with(nolock)
	on sb.item = pm.ItemCode
where pm.Reorderable = 'Y' or pm.ReorderableItem = 'Y'


--Subset of the xacns table being used, plus desired indecies & previous entries
--     declare @eDate datetime = dateadd(DD,-1,getdate())
drop table if exists #xacnsWithPrevs
select ng.Loc
	,ng.u
    ,row_number() over(partition by ng.Loc,sb.RptIt order by ng.Date,ng.u)[unq] --[ru]
    ,row_number() over(partition by ng.Loc,ng.Item order by ng.Date desc,ng.u desc)[ItemUnq] --[du]
    ,row_number() over(partition by ng.Loc,ng.Item,ng.Xacn order by ng.Date desc,ng.u desc)[XacnItemUnq] --[dxu]
	,ng.Item
	,sb.RptIt
	,sb.icCost[Cost]
	,ng.Date
	,ng.flow
	,ng.Xacn
	,ng.Qty
	,ng.Inv
	,ng.pshQty
	,ng.mdQty
	,ng.SldVal
	,ng.mdSldVal
	,ng.SldFee
	,ng.InvQ[grssInv]
    ,ng.InvQ + sa.fAdjQ[corInv] --[fInvQ]
    -- ,case when ng.u = 1 then 0 else ag.aFAjInvAge end[fInvA]
	,cast(null as int)[pvUnq]
	,cast(null as datetime)[pvDate]
	,cast(null as varchar(10))[pvflow]
	,cast(null as int)[pvQty]
	,cast(null as int)[pvInv]
	,cast(null as int)[pvGrssInv]
	,cast(null as int)[pvCorInv]
into #xacnsWithPrevs
from ReportsView..hroXacns ng
	inner join ReportsView..hroXacns_Items sb with(nolock) on ng.ItemCode = sb.ItemCode
	inner join #ActiveRptIts ar on sb.RptIt = ar.RptIt
    inner join ReportsView..hroXacns_SetAdjs sa with(nolock) on ng.Loc = sa.Loc 
        and ng.Item = sa.Item and ng.ItemCode = sa.ItemCode and ng.crSet = sa.crSet and ng.nxIn = sa.nxIn
    -- left join ReportsView..hroXacns_Ages ag with(nolock) on ng.Loc = ag.Loc 
    --     and ng.Item = ag.Item and ng.ItemCode = ag.ItemCode and ng.u = ag.u
where ng.[Date] < @eDate
	and ng.Loc not in ('00011','00020','00027','00028','00042','00052','00056','00060','00063','00079','00089','00092','00093','00101','00106')
	

update tar
set pvUnq = xp.unq
	,pvDate = xp.Date
	,pvflow = xp.flow
	,pvQty = xp.Qty
	,pvInv = xp.Inv
	,pvGrssInv = xp.GrssInv
	,pvCorInv = xp.CorInv
from #xacnsWithPrevs tar left outer join #xacnsWithPrevs xp 
	on tar.Loc = xp.Loc and tar.RptIt = xp.RptIt and tar.unq = xp.unq + 1


----With CorInv calculations too................
drop table if exists #cxZID
select xp.*
	--fuzzyZeroInvDays, a little more discriminating that just 180 days of inactivity
	,case when (xp.corInv - ISNULL(-xp.Qty,xp.Inv) < 1 --Does this entry zero out inventory?
				and (xp.flow = 'in' or (xp.flow = 'set' and xp.corInv = 0))  --Did this entry SET inventory to 0 or s'this adding qty to inventory?
				and (xp.pvflow = 'out' --Was the previous entry outbound OR was
						or xp.pvCorInv < 1 
						or (xp.pvflow = 'set' and xp.pvCorInv = 0) 
						or (xp.pvflow = 'in' and xp.pvQty = 0 and xp.pvCorInv = 0)))
			--Couldn't have been out of stock if it was sold or trashed or SICC'd into somethnig nonzero (Are all of these trustworthy??)
			or (DATEDIFF(dd,xp.pvDate,xp.Date) > 180 and (xp.flow not in ('out','set') or (xp.flow = 'set' and xp.CorInv > 0))) 
			then DATEDIFF(dd,xp.pvDate,xp.Date) else 0 end [fZID]
	--Absolute*, for certain*, days with zero inventory. *At least according to the system.
	,case when xp.corInv - ISNULL(xp.Qty,xp.Inv) < 1 
			and (xp.flow = 'in' or (xp.flow = 'set' and xp.corInv = 0))
			and (xp.pvflow = 'out'
					or xp.pvCorInv < 1 
					or (xp.pvflow = 'set' and xp.pvCorInv = 0) 
					or (xp.pvflow = 'in' and xp.pvQty = 0 and xp.pvCorInv = 0))
			then DATEDIFF(dd,xp.pvDate,xp.Date) else 0 end [aZID]
			
	----fuzzyZeroInvDays Diagnostics
	--,case when xp.corInv - ISNULL(-xp.Qty,xp.Inv) < 1 then 1000 else 0 end
	--			+ case when xp.flow = 'in' then 100 
	--					when (xp.flow = 'set' and xp.corInv = 0) then 200
	--					else 0 end
	--			+ case when (xp.pvflow = 'out' 
	--					or xp.pvCorInv < 1 
	--					or (xp.pvflow = 'set' and xp.pvCorInv = 0) 
	--					or (xp.pvflow = 'in' and xp.pvQty = 0 and xp.pvCorInv = 0)) then 10
	--					else 0 end
	--		+ case when (DATEDIFF(dd,xp.pvDate,xp.Date) > 180 then 20
	--			and (xp.flow not in ('out','set') or (xp.flow = 'set' and xp.CorInv > 0))) 
	--		then DATEDIFF(dd,xp.pvDate,xp.Date) else 0 end [fZID]
	----ZeroInventoryDays Diagnostics
	--,case when xp.corInv - ISNULL(xp.Qty,xp.Inv) < 1 
	--		and (xp.flow = 'in' or (xp.flow = 'set' and xp.corInv = 0))
	--		and (xp.pvflow = 'out'
	--				or xp.pvCorInv < 1 
	--				or (xp.pvflow = 'set' and xp.pvCorInv = 0) 
	--				or (xp.pvflow = 'in' and xp.pvQty = 0 and xp.pvCorInv = 0))
	--		then DATEDIFF(dd,xp.pvDate,xp.Date) else 0 end [aZID]

	--Running Inventory Levels Calculation	  
	,sum(case when xp.ItemUnq = 1 then xp.CorInv else 0 end) over(partition by xp.Loc, xp.RptIt)[LGI]
	,first_Value(xp.Date) over(partition by xp.Loc, xp.Item order by xp.unq desc)[MaxDt]
into #cxZID
from #xacnsWithPrevs xp



--Loc-RptIt Rollups......
drop table if exists #cItLocRU
select xz.Loc
	,xz.RptIt
	,sum(case when xz.Xacn in ('CDC','Drps') then xz.Qty else 0 end)[ShipQty]
	,sum(case when xz.flow in ('in') then xz.Qty else 0 end)[QtyInb]
	,sum(case when xz.Xacn in ('Sale') then -xz.Qty else 0 end)[SoldQty]
	,sum(case when xz.Xacn in ('Rtrn') then xz.Qty else 0 end)[RtrnQty]
	,sum(case when xz.Xacn in ('Sale','Rtrn') then -xz.Qty else 0 end)[QtySld]
	,sum(case when xz.Xacn in ('Sale') then isnull(-xz.mdQty,0) else 0 end)[mdSoldQty]
	,sum(case when xz.Xacn in ('Rtrn') then isnull(xz.mdQty,0) else 0 end)[mdRtrnQty]
	,sum(case when xz.Xacn in ('Sale','Rtrn') then isnull(-xz.mdQty,0) else 0 end)[QtyMDSld]
	,sum(case when xz.Xacn in ('iSale','iRtrn','hSale','hRtrn') then -xz.Qty else 0 end)[OnlQty]
	,count(case when xz.Xacn in ('Sale','Rtrn') then xz.Qty end)[SldXacns]
	,sum(isnull(xz.SldVal,0))[SoldVal]
	,sum(isnull(xz.mdSldVal,0))[MDSoldVal]
	,sum(case when xz.Xacn in ('iSale','iRtrn','hSale','hRtrn') then isnull(xz.SldVal,0) else 0 end)[OnlVal]
	,sum(case when xz.Xacn in ('iSale','iRtrn','hSale','hRtrn') then isnull(xz.SldFee,0) else 0 end)[OnlFee]
	,sum(case when xz.Xacn in ('Tsh','Dnt') then -xz.Qty else 0 end)[TshDntQty]
	,sum(case when xacn in ('StSi','StSo') then Qty else 0 end)[netXfers]
	,sum(case when xacn = 'StSi' then Qty else 0 end)[iStSQty]
	,sum(case when xacn = 'StSo' then -Qty else 0 end)[oStSQty]
	,sum(case when xz.Xacn in ('Tsh') then -xz.Qty else 0 end)[TshQty]
	,sum(case when xz.Xacn in ('Dnt') then -xz.Qty else 0 end)[DntQty]
	,sum(case when xz.Xacn in ('Dmg') then -xz.Qty else 0 end)[DmgQty]
	,sum(case when xz.Xacn in ('Bsm') then -xz.Qty else 0 end)[BksQty]
	,sum(case when xz.Xacn in ('Mkt') then -xz.Qty else 0 end)[MktQty]
	,sum(case when xz.Xacn in ('vRtn') then -xz.Qty else 0 end)[VndQty]
	,min(xz.Date)[minDt]
	,max(xz.Date)[maxDt]
	,min(case when xz.xacn in ('CDC','Drps') then Date end)[RcvDt]
	,case when min(xz.Date) = max(xz.Date) then 1 else ceiling(datediff(HH,min(xz.Date),max(xz.Date))/24.0) end[NetDays]
	,sum(xz.fZID)[fZID]
	,sum(xz.aZID)[aZID]
	,case when sum(xz.fZID) > sum(xz.aZID) then sum(xz.fZID) else sum(xz.aZID) end[ZID]
	,datediff(dd,max(xz.Date),getdate())-1[DaysToToday]
	,avg(xz.LGI)[LGI]
	,cast(null as numeric(27,21))[TotInvDays]
	,cast(null as numeric(27,21))[RoS]
	,cast(null as numeric(16,12))[PctNM]
	,cast(null as numeric(16,12))[PctSld]
	,cast(null as numeric(16,12))[zRoS]
	,cast(null as numeric(16,12))[zPctNM]
into #cItLocRU 
from #cxZID xz 
group by xz.RptIt
	,xz.Loc




-- select top 1000* from #cItLocRU

drop table if exists ReportsView..hroSuggOrds_BaseData
create table ReportsView.dbo.hroSuggOrds_BaseData
	([Loc] [char](5) NOT NULL,
	[RptIt] [varchar](20) NOT NULL,
	[ShipQty] [int] NULL,
	[QtyInb] [int] NULL,
	[SoldQty] [int] NULL,
	[RtrnQty] [int] NULL,
	[QtySld] [int] NULL,
	[mdSoldQty] [int] NULL,
	[mdRtrnQty] [int] NULL,
	[QtyMDSld] [int] NULL,
	[OnlQty] [int] NULL,
	[SldXacns] [int] NULL,
	[SoldVal] [money] NULL,
	[MDSoldVal] [money] NULL,
	[OnlVal] [money] NULL,
	[OnlFee] [money] NULL,
	[TshDntQty] [int] NULL,
	[netXfers] [int] NULL,
	[iStSQty] [int] NULL,
	[oStSQty] [int] NULL,
	[TshQty] [int] NULL,
	[DntQty] [int] NULL,
	[DmgQty] [int] NULL,
	[BksQty] [int] NULL,
	[MktQty] [int] NULL,
	[VndQty] [int] NULL,
	[minDt] [datetime] NULL,
	[maxDt] [datetime] NULL,
	[RcvDt] [datetime] NULL,
	[NetDays] [numeric](17, 0) NULL,
	[fZID] [int] NULL,
	[aZID] [int] NULL,
	[ZID] [int] NULL,
	[DaysToToday] [int] NULL,
	[LGI] [int] NULL,
	[TotInvDays] [numeric](27, 21) NULL,
	[RoS] [numeric](27, 21) NULL,
	[PctNM] [numeric](16, 12) NULL,
	[PctSld] [numeric](16, 12) NULL,
	[zRoS] [numeric](16, 12) NULL,
	[zPctNM] [numeric](16, 12) NULL
	,constraint PK_hroSuggOrdsBaseData primary key(Loc,RptIt))

insert into ReportsView..hroSuggOrds_BaseData
select *
from #cItLocRU

/*
--     select * from ReportsView..hroSuggOrds_BaseData into #cItLocRU
drop table if exists ReportsView..hroSuggOrds_BaseData

insert into ReportsView..hroSuggOrds_BaseData
select *
-- into ReportsView..hroSuggOrds_BaseData
from #cItLocRU
*/


--Finally calculating some of the needed fields--
update ReportsView..hroSuggOrds_BaseData
	set
	--Total days in inventory, excluding days estimated/calculated as not having any qty in stock
	TotInvDays = isnull(nullif(NetDays - ZID + case when LGI = 0 then 0 when DaysToToday > 180 then 180 else DaysToToday end,0),1)

	--Rate of Sale calculated only for days when there was qty in stock (& therefore available to be sold)
	,RoS = SoldQty * 1.0
			/isnull(nullif(NetDays - ZID + case when LGI = 0 then 0 when DaysToToday > 180 then 180 else DaysToToday end,0),1)

	,PctNM = (SoldQty - QtyMDSld) * 1.0 / isnull(nullif(SoldQty + TshDntQty,0),1)
	-- TODO: Should donate xfers be removed from the denominator?
	,PctSld = SoldQty * 1.0 / nullif(ShipQty + RtrnQty + iStSQty - oStSQty - BksQty - DmgQty,0)
from ReportsView..hroSuggOrds_BaseData 



-- set 0 as the min RoS a store can have. 
-- Though this should no longer be an issue since returns were removed from the RoS calc.
update ReportsView..hroSuggOrds_BaseData
set RoS =  0 
from ReportsView..hroSuggOrds_BaseData tar
where RoS < 0


drop table if exists #AvgsStDevs
select RptIt
	,sum(SoldQty-mdSoldQty) * 1.0 / isnull(nullif(sum(SoldQty + TshDntQty),0),1)[ChPctNM]
	,sum(SoldQty) * 1.0 / isnull(nullif(sum(ShipQty),0),1)[ChPctSld]
	--Only factor in stores that have received the item at all
	,avg(case when QtyInb > 0 then RoS end)[avgRoS]
	,stdevp(RoS)[stdvRoS]
	--Only factor in the PctNM of stores that have had sales
	,avg(case when SldXacns > 0 then PctNM end)[avgPctNM]
	,stdevp(PctNM)[stdvPctNM]
	,cast(avg(cast(RcvDt as float)) as datetime)[avgRcvDt]
	,datediff(DD,min(RcvDt),max(RcvDt))[spanRcvDt]
	,count(case when SoldQty = 0 then Loc end)*1.0
		/ nullif(count(case when SoldQty > 0 then Loc end),0)[PctLocsSld]
into #AvgsStDevs
from ReportsView..hroSuggOrds_BaseData
group by RptIt


--Adds z-scores for some calculated fields...
update ReportsView..hroSuggOrds_BaseData
	set
	zRoS = case when ad.stdvRoS <> 0 then (bd.RoS - ad.avgRoS) / ad.stdvRoS end
	,zPctNM = isnull(case when ad.stdvPctNM <> 0 then (bd.PctNM - ad.avgPctNM) / ad.stdvPctNM end,0)
from ReportsView..hroSuggOrds_BaseData bd
	inner join #AvgsStDevs ad on bd.RptIt = ad.RptIt



-- Create tables on Sage 
-------------------------------------------------------------------------
/*
-- Rebuild existing table-------------------
drop table if exists #temp
select * into #temp 
from ReportsView.dbo.hroSuggOrds_ItemEquivs

drop table if exists ReportsView.dbo.hroSuggOrds_ItemEquivs

insert into ReportsView.dbo.hroSuggOrds_ItemEquivs
select * from #temp


-- Build out NEW table-------------------
drop table if exists ReportsView.dbo.hroSuggOrds_ItemEquivs

create table ReportsView.dbo.hroSuggOrds_ItemEquivs(
	[PurchaseFromVendorID] [varchar](10) NOT NULL,
	[RptIt] [varchar](20) NULL,
	[Item] [char](20) NULL,
	[ItemCode] [char](20) NOT NULL,
	[Section] [varchar](10) NULL,
	[Scheme] [varchar](20) NULL,
	[aScheme] [varchar](20) NULL,
	[PO] [varchar](6) NOT NULL,
	[Title] [varchar](70) NOT NULL,
	[Cost] [money] NOT NULL,
	[Price] [money] NOT NULL,
	[Rord] [char](2) NULL,
	[CaseQty] [int] NULL,
	[AvailWMS] [numeric](38, 5) NOT NULL,
	[note] [varchar](27) NOT NULL,
	[ChPctNM] [numeric](24, 12) NULL,
	[ChPctSld] [numeric](24, 12) NULL,
	[avgPctNM] [numeric](38, 12) NULL,
	[avgRcvDt] [datetime] NULL,
	[avgRoS] [numeric](38, 21) NULL,
	[spanRcvDt] [int] NULL,
	[stdvPctNM] [float] NULL,
	[stdvRoS] [float] NULL,
	[PctLocsSld] [numeric](24, 12) NULL,
	[Src] [varchar](5) NULL,
	constraint [PK_hroSuggOrdsItemEquivs] primary key clustered ([ItemCode] ASC)
		with (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) on [PRIMARY]
) on [PRIMARY]

*/

drop table if exists ReportsView.dbo.hroSuggOrds_ItemEquivs
select ri.PurchaseFromVendorID
	,ng.RptIt
	,ng.Item
	,ng.ItemCode
	,ltrim(rtrim(pm.SectionCode))[Section]
	,ltrim(rtrim(pm.PMD_SchemeID))[Scheme]
	,cast(null as varchar(20))[aScheme]
	,pm.LastPurchaseOrder[PO]
	,pm.Title
	,pm.Cost
	,pm.Price
	,pm.ReorderableItem + pm.Reorderable[Rord]
	,case when pm.UnitsPerCase = 0 then 1 else pm.UnitsPerCase end[CaseQty]
	,isnull(ii.InvQ,0)[AvailWMS]
	,case count(case when pm.Reorderable = 'Y' then ng.ItemCode end) over(partition by ng.RptIt)
		when 0 then 'No Reorderable Items!'
		when 1 then ''
		else 'Multiple Reorderable Items!' end[note]
	,ad.ChPctNM
	,ad.ChPctSld
	,ad.avgPctNM
	,ad.avgRcvDt
	,ad.avgRoS
	,ad.spanRcvDt
	,ad.stdvPctNM
	,ad.stdvRoS
	,ad.PctLocsSld
	,'hro'[Src]
into ReportsView.dbo.hroSuggOrds_ItemEquivs
from ReportsView..hroXacns_Items ng
	inner join ReportsView..vw_DistributionProductMaster pm with(nolock) on ng.ItemCode = pm.ItemCode
	inner join ReportsView..vw_DistributionProductMaster ri with(nolock) on ng.RptIt = ri.ItemCode
	inner join #AvgsStDevs ad on ng.RptIt = ad.RptIt
    left join #icInv ii on ng.ItemCode = ii.ItemCode


update ReportsView..hroSuggOrds_ItemEquivs
	set
	ChPctNM = ad.ChPctNM
	,ChPctSld = ad.ChPctSld
	,avgPctNM = ad.avgPctNM
	,avgRcvDt = ad.avgRcvDt
	,avgRoS = ad.avgRoS
	,spanRcvDt = ad.spanRcvDt
	,stdvPctNM = ad.stdvPctNM
	,stdvRoS = ad.stdvRoS
	,PctLocsSld = ad.PctLocsSld
from ReportsView..hroSuggOrds_ItemEquivs tar
	inner join #AvgsStDevs ad on tar.RptIt = ad.RptIt



-- Assigns Section-based Scheme ONLY TO items with a weird scheme
--------------------------------------------------------------------------
update ReportsView..hroSuggOrds_ItemEquivs
	set aScheme = case when tar.Scheme in ('CS','TTB ONLY','RESTOCK','SHELFX2')
							or iv.Scheme is null then ss.DefaultScheme
						else tar.Scheme end
from ReportsView..hroSuggOrds_ItemEquivs tar
	left join ReportsView..ShpSld_SbjScnCapMap ss
		on tar.Section = ss.Section
	left join (select Scheme_ID collate database_default as Scheme
				from wms_ils..HPB_SCHEME_HEADER with(nolock)
				where SCHEME_TYPE = 'Standard')iv on tar.Scheme = iv.Scheme



