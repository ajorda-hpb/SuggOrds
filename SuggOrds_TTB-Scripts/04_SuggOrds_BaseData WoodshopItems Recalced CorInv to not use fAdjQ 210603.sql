

--For TTB Suggested Orders, an additional month allows for the 
--projected receipt of in-transit shipments to have happened.
declare @eDate datetime
set @eDate = dateadd(DD,28,getdate())


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
from ReportsView..ngXacns_Items it inner join wmsInv wi 
    on wi.ItemCode = it.ItemCode
group by it.ItemCode
    ,it.RptIt



--Subset of the xacns table being used, plus desired indecies & previous entries
--     declare @eDate datetime = dateadd(DD,28,getdate())
drop table if exists #xacnsWithPrevs
select ng.Loc
	,ng.u
    ,row_number() over(partition by ng.Loc,RptIt order by ng.Date,ng.u)[unq] --[ru]
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
    ,ng.InvQ + isnull(sa.AdjQ,0) [corInv] --[fInvQ]
    ,case when ng.u = 1 then 0 else isnull(ag.aAjInvAge,0) end[fInvA]
	,cast(null as int)[pvUnq]
	,cast(null as datetime)[pvDate]
	,cast(null as varchar(10))[pvflow]
	,cast(null as int)[pvQty]
	,cast(null as int)[pvInv]
	,cast(null as int)[pvGrssInv]
	,cast(null as int)[pvCorInv]
into #xacnsWithPrevs
from ReportsView..ngXacns ng
	-- inner join #subset sb on ng.ItemCode = sb.ItemCode
	inner join ReportsView..ngXacns_Items sb with(nolock) on ng.ItemCode = sb.ItemCode
    left join ReportsView..ngXacns_SetAdjs sa with(nolock) on ng.Loc = sa.Loc 
        and ng.ItemCode = sa.ItemCode and ng.crSet = sa.crSet and ng.nxIn = sa.nxIn
    left join ReportsView..ngXacns_Ages ag with(nolock)
        on ng.ItemCode = ag.ItemCode and ng.Loc = ag.Loc and ng.u = ag.u
where ng.[Date] < @eDate
	and ng.Loc not in ('00011','00020','00027','00028','00042','00052','00056','00060','00063','00079','00089','00092','00093','00101','00106')
    and sb.RptIt in ('00000000000002008143','00000000000002008149','00000000000002009009')

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



-- select * 
-- from ReportsView..ngXacns_Items 
-- where item = '00000000000002007046'

-- select *
-- from #xacnsWithPrevs
-- where Loc = '00001' and item = '00000000000002007046' 
-- order by 1,2

-- select Loc,RptIt,Item,u,unq,ItemUnq,XacnItemUnq,Date,Xacn,Qty,Inv,grssInv,corInv,LGI,fZID,aZID
-- from #cxZID
-- where Loc = '00001' and RptIt = '00000000000002008149'
-- order by Loc,RptIt,Item,u



--Finally calculating some of the needed fields--
update #cItLocRU
	set
	--Total days in inventory, excluding days estimated/calculated as not having any qty in stock
	TotInvDays = isnull(nullif(NetDays - ZID + case when LGI = 0 then 0 when DaysToToday > 180 then 180 else DaysToToday end,0),1)

	--Rate of Sale calculated only for days when there was qty in stock (& therefore available to be sold)
	,RoS = SoldQty * 1.0
			/isnull(nullif(NetDays - ZID + case when LGI = 0 then 0 when DaysToToday > 180 then 180 else DaysToToday end,0),1)

	,PctNM = (SoldQty - QtyMDSld) * 1.0 / isnull(nullif(SoldQty + TshDntQty,0),1)
	-- TODO: Should donate xfers be removed from the denominator?
	,PctSld = SoldQty * 1.0 / nullif(ShipQty + RtrnQty + iStSQty - oStSQty - BksQty - DmgQty,0)
	-- Alternate version that backs out returns from total sold, per excel versions on & after Aug 28, 2020, & used to force agreement with the Round 7 TTB orders.
	-- ,PctSld = QtySld * 1.0 / nullif(ShipQty + RtrnQty + iStSQty - oStSQty - BksQty - DmgQty,0)
from #cItLocRU


update #cItLocRU
set RoS =  0 
from #cItLocRU tar
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
from #cItLocRU
group by RptIt


--Adds z-scores for some calculated fields...
update #cItLocRU
	set
	zRoS = case when ad.stdvRoS <> 0 then (bd.RoS - ad.avgRoS) / ad.stdvRoS end
	,zPctNM = isnull(case when ad.stdvPctNM <> 0 then (bd.PctNM - ad.avgPctNM) / ad.stdvPctNM end,0)
from #cItLocRU bd
	inner join #AvgsStDevs ad on bd.RptIt = ad.RptIt



select Loc,RptIt,ShipQty,SoldQty,RtrnQty,OnlQty,TshDntQty,iStSQty,oStSQty,LGI 
    ,minDt,maxDt,NetDays,fZID,aZID,ZID
--    select *
from #cItLocRU
-- where Loc = '00001'
order by 1,2
