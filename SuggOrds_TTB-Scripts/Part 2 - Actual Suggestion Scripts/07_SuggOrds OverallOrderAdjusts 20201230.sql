

-- select RptIt
--     ,sum(i.OrderQty)
-- --    select *
-- from ReportsView..SuggOrds_ItemEquivs i 
--     -- inner join ReportsView..ngXacns x on x.ItemCode = i.ItemCode
-- where i.RptIt in ('00000000000002001163','00000000000002011036','00000000000002011037','00000000000002011038','00000000000002011039','00000000000002011040','00000000000002011041')
-- group by RptIt

-- select Reorderable,* from ReportsView..vw_DistributionProductMaster  
-- where itemcode in ('00000000000002001163','00000000000002011036','00000000000002011037','00000000000002011038','00000000000002011039','00000000000002011040','00000000000002011041')

-- select Item collate database_default[Item]
--     ,right('00000000000000000000'+Item,20) collate database_default[ItemCode]
--     ,COMPANY collate database_default[Cmp]
--     ,max(a.LOC_INV_ATTRIBUTE9)[CasePick]
--     ,max(a.LOC_INV_ATTRIBUTE3)[InvAttrib]
--     ,sum(ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY)[WmsInvQ]
--     ,sum(case when LOCATION_TEMPLATE = 'FWD Pick' then ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY else 0 end)[WmsFpaInvQ]
-- from wms_ils..location_inventory i with(nolock)
--     left join wms_ils..LOCATION_INVENTORY_ATTRIBUTES a with(nolock)
--         on i.LOC_INV_ATTRIBUTES_ID = a.OBJECT_ID
-- where item in (
--     '2001163',
--     '2011036',
--     '2011037',
--     '2011038',
--     '2011039',
--     '2011040',
--     '2011041')
-- group by Item collate database_default
--     ,right('00000000000000000000'+Item,20) collate database_default
--     ,COMPANY collate database_default
-- having sum(ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY) > 0


-- Which set of items are orders being generated for?------------------------
-----------------------------------------------------------------------------
-- setID 20 = params for FIXED 2021 Wk20 cycle.
--     select * from ReportsView..SuggOrds_Params order by SetID desc
declare @UseSetID int = 45


drop table if exists #ItemInventory
select ie.RptIt
    ,ie.ItemCode
    ,ie.PurchaseFromVendorID[pfVendor]
    ,ie.Section
    ,ie.aScheme
    ,ie.Title
    ,ie.CaseQty
    ,ie.Cost
    ,ie.Price
    ,ie.Rord
    ,li.WmsInvQ
    ,li.WmsFpaInvQ
    ,count(ie.ItemCode) over(partition by ie.RptIt)[NumIts]
    ,count(case when ie.Rord = 'YY' then ie.ItemCode end) over(partition by ie.RptIt)[NumRords]
    ,row_number() over(partition by ie.RptIt order by ie.Rord desc,li.WmsInvQ)[ItRnks]
into #ItemInventory
from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
    inner join (select Item collate database_default[Item]
                    ,right('00000000000000000000'+Item,20) collate database_default[ItemCode]
                    ,COMPANY collate database_default[Cmp]
                    ,max(a.LOC_INV_ATTRIBUTE9)[CasePick]
                    ,max(a.LOC_INV_ATTRIBUTE3)[InvAttrib]
                    ,sum(ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY)[WmsInvQ]
                    ,sum(case when LOCATION_TEMPLATE = 'FWD Pick' then ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY else 0 end)[WmsFpaInvQ]
                from wms_ils..location_inventory i with(nolock)
                    left join wms_ils..LOCATION_INVENTORY_ATTRIBUTES a with(nolock)
                        on i.LOC_INV_ATTRIBUTES_ID = a.OBJECT_ID
                group by Item collate database_default
                    ,right('00000000000000000000'+Item,20) collate database_default
                    ,COMPANY collate database_default
                having sum(ON_HAND_QTY-SUSPENSE_QTY-ALLOCATED_QTY) > 0
            )li on ie.ItemCode = li.ItemCode
where ie.RptIt in (select distinct RptIt from ReportsView..SuggOrds_OrigOrders)


-- Looking for weird shit-------------------------------------
select 'Has multiple currently reorderable ItemCodes!'[No Results = WIN], *
from #ItemInventory
where NumRords > 1
union all     
select 'multiple ItemCodes with inventory under 1 RptIt!'[No Results = WIN], *
from #ItemInventory
where NumIts > 1
order by RptIt,ItRnks,ItemCode



-- Item Totals------------------------------------------------
drop table if exists #InvOrds_prep
select ci.pfVendor
    ,ci.Section
    ,oo.RptIt
    ,ci.ItemCode
    ,ci.Title
    ,ci.Cost[eaCost]
    ,ci.Price[eaPrice]
    ,ci.aScheme
    ,count(distinct oo.Loc)[TotalLocs]
    ,count(distinct case when oo.aQoH > 0 then oo.Loc end)[LocsWithInv]
    ,count(distinct case when oo.OrderQty > 0 then oo.Loc end)[LocsWithOrd]
    ,sum(oo.aSchQty)[ChainSchQ]
    ,sum(oo.aQoH)[ChainInvQ]
    ,sum(oo.aRoS)[ChainRoS]
    ,sum(OrderQty)[ChainOrdQ]
    ,ci.Cost * sum(OrderQty)[ChainOrdC]
    ,ci.WmsInvQ
    ,ci.WmsFpaInvQ
    ,case when ci.WmsInvQ >= sum(OrderQty) then sum(OrderQty) else ci.WmsInvQ end[InvAdjChainOrdQ]
    ,ci.Cost * case when ci.WmsInvQ >= sum(OrderQty) then sum(OrderQty) else ci.WmsInvQ end[InvAdjChainOrdC]
    ,ci.WmsInvQ - case when ci.WmsInvQ >= sum(OrderQty) then sum(OrderQty) else ci.WmsInvQ end[RemWmsInvQ]
    ,ci.Cost * (ci.WmsInvQ - case when ci.WmsInvQ >= sum(OrderQty) then sum(OrderQty) else ci.WmsInvQ end)[RemWmsInvC]
    ,cast(null as numeric(19,8))[FpaFill]
    ,cast(null as numeric(19,8))[PctFpa]
into #InvOrds_prep
from ReportsView..SuggOrds_OrigOrders oo with(nolock)
    inner join #ItemInventory ci on oo.RptIt = ci.RptIt and ci.ItRnks = 1
where oo.SetID = @UseSetID 
    and oo.OrderQty > 0 
group by ci.pfVendor
    ,ci.Section
    ,oo.RptIt
    ,ci.ItemCode
    ,ci.Title
    ,ci.Cost
    ,ci.Price
    ,ci.aScheme
    ,ci.WmsInvQ
    ,ci.WmsFpaInvQ

update #InvOrds_prep
set FpaFill = case when WmsFpaInvQ >= InvAdjChainOrdQ then 1
                    when WmsFpaInvQ < 0 then 0
                    else isnull(WmsFpaInvQ * 1.0 / nullif(InvAdjChainOrdQ,0),0) end
    ,PctFpa = cast(WmsFpaInvQ as numeric(19,8)) / WmsInvQ


drop table if exists #InvOrds
select ip.*
    ,dense_rank() over(partition by pfVendor order by FpaFill desc)[ItRnkInVndrByFpaFill]
    ,dense_rank() over(partition by pfVendor order by TotalLocs desc)[ItRnkInVndrByTotalLocs]
    ,dense_rank() over(partition by pfVendor order by ChainOrdQ desc)[ItRnkInVndrByChainOrdQ]
    ,dense_rank() over(partition by Section order by FpaFill desc)[ItRnkInSecnByFpaFill]
    ,dense_rank() over(partition by Section order by TotalLocs desc)[ItRnkInSecnByTotalLocs]
    ,dense_rank() over(partition by Section order by ChainOrdQ desc)[ItRnkInSecnByChainOrdQ]
	,case when ChainOrdQ > WmsInvQ then 'Oversold' 
          when RemWmsInvQ between 1 and 50 then 'Shorts-eligible' 
          else '' end[InvConsq]
into #InvOrds
from #InvOrds_prep ip



/*-- Store Totals------------------------------------------------
select oo.Loc
    ,ci.pfVendor
    ,ci.Section
    ,count(oo.RptIt)[NumIts]
    ,sum(OrderQty)[OrderQty]
    ,sum(OrderQty * ci.eaCost)[OrderCost]
    ,sum(case when OrderCat = 'NO' then OrderQty else 0 end)[noQty]
    ,sum(case when OrderCat = 'QS' then OrderQty else 0 end)[qsQty]
    ,sum(case when OrderCat = 'RS' then OrderQty else 0 end)[rsQty]
    ,sum(case when OrderCat = 'SS' then OrderQty else 0 end)[ssQty]

    ,count(distinct case when OrderCat = 'NO' then oo.RptIt end)[noIts]
    ,count(distinct case when OrderCat = 'QS' then oo.RptIt end)[qsIts]
    ,count(distinct case when OrderCat = 'RS' then oo.RptIt end)[rsIts]
    ,count(distinct case when OrderCat = 'SS' then oo.RptIt end)[ssIts]
    
    ,sum(case when OrderCat = 'NO' then OrderQty * ci.eaCost else 0 end)[noCost]
    ,sum(case when OrderCat = 'QS' then OrderQty * ci.eaCost else 0 end)[qsCost]
    ,sum(case when OrderCat = 'RS' then OrderQty * ci.eaCost else 0 end)[rsCost]
    ,sum(case when OrderCat = 'SS' then OrderQty * ci.eaCost else 0 end)[ssCost]
from ReportsView..SuggOrds_OrigOrders oo with(nolock)
    inner join #InvOrds ci on oo.RptIt = ci.RptIt 
where oo.OrderQty > 0
    and oo.SetID = @UseSetID
group by oo.Loc
    ,ci.pfVendor
    ,ci.Section
order by oo.Loc 
    ,ci.pfVendor
*/

/*------------------------------------------------------------
---Modify order details based on limited copies available-----
Allocation logics (schemes) handle the situation of 
"We don't have enough copies for everyone to get what they 
	ordered, so who gets what?"
E.g. We have 300 copies, but stores ordered 600. 
	Does everyone get half? 
	Do half the stores get everything? 
	Something... in between? 
-------------------------------------------------------------
UPDATE 3/1/19: Generalized to handle case quantities 
	Note that @CaseQty = 1 corresponds to no case quantity.

drop table if exists #OrdsImport
drop table if exists #ItemInventory
drop table if exists #Orders
drop table if exists #SingleCaseOrders
drop table if exists #SequencedSingleCaseOrders
*/-----------------------------------------------------------


--Import Store Orders Data & add OrdID-----------------------
--     declare @UseSetID int = 19
drop table if exists #Orders
select o.Loc
    ,o.RptIt
    ,i.ItemCode
    ,i.CaseQty
    ,o.OrderQty
    ,row_number() over(order by o.RptIt,o.Loc)[OrdID]
into #Orders 
from ReportsView..SuggOrds_OrigOrders o with(nolock)
    inner join ReportsView..SuggOrds_ItemEquivs ie on o.RptIt = ie.ItemCode
    inner join #ItemInventory i on o.RptIt = i.RptIt and i.ItRnks = 1
	inner join #InvOrds ivo on i.ItemCode = ivo.ItemCode
where o.SetID = @UseSetID
	and ie.PurchaseFromVendorID in ('TEXASBKMNA','TEXASBKMNB','TEXASBKNON','TEXASSTATI','TEXASBKPUZ','TEXASBKUPC')
    and i.WmsInvQ > 0
-- It's there because we only NEED to run mva/bottom-fill on stuff we DONT have enough inventory for.
	and i.WmsInvQ < ivo.ChainOrdQ  -- WHY was this here?!???
    -- and o.RptIt in ('00000000000002001163','00000000000002011036','00000000000002011037','00000000000002011038','00000000000002011039','00000000000002011040','00000000000002011041')
    -- and o.RptIt = '00000000000002002137'

-- select sum(OrderQty) from #Orders where RptIt = '00000000000002002137'

/*-----------------------------------------------------------------
Next step is to reformat #Orders into #SingleCaseOrders. 
One record in #Orders (for OrderQty, aka # copies ordered by a store) 
becomes x records in #SingleCaseOrders, where x = OrderQty/CaseQty, 
where each record is for CaseQty copies.
E.g., if CaseQty = 1 and a store orders 5 copies, 
there'll be 5 records in #SingleCaseOrders for one case/copy each.
*/----------------------------------------------------------------


drop table if exists #SingleCaseOrders
create table #SingleCaseOrders
	(ItemCode nvarchar(20)
	,Loc nvarchar(5)
	,OrderQty numeric(9,0)
	,CaseQty numeric(9,0)
	,[Case] numeric(9,0)) 


--Vars for looping...
declare @CurOrdID int
declare @MaxOrdID int
declare @Case int
declare @OrderQty int
declare @CaseQty int

--Loop over all the orders
set nocount on
set @CurOrdID = 1
set @MaxOrdID = (select max(OrdID) from #Orders)
while @CurOrdID <= @MaxOrdID
BEGIN
	--Loop over OrderQty to add lines in case increments
	set @CaseQty = (select max(CaseQty) from #Orders where OrdID = @CurOrdID)
	set @OrderQty = (select max(OrderQty) from #Orders where OrdID = @CurOrdID)
	set @Case = 1
	while @Case * @CaseQty <= @OrderQty
	BEGIN
		insert into #SingleCaseOrders
		select o.ItemCode
			,Loc
			,@OrderQty
			,@CaseQty
			,@Case
		from #Orders o
		where o.OrdID = @CurOrdID

		--End loop if another case would exceed OrderQty
		set @Case = @Case + 1
		if @Case * @CaseQty > @OrderQty
			BREAK
		else
			CONTINUE
	END

	--End loop if that was the last order
	set @CurOrdID = @CurOrdID + 1
	if @CurOrdID > @MaxOrdID
		BREAK
	else
		CONTINUE
END

/*----------------------------------------------------------------
Once orders have been reformatted, i.e. each case has its own row, 
the cases/rows are ranked/sequenced by how we want them allocated
*/----------------------------------------------------------------
drop table if exists #SequencedSingleCaseOrders
select *
	/*---------------------------------------------------------------------------------
	Bottom-fill Logic = For a given Item/Title, cases are allocated in this order: 
	1. Asc by Case: Everyone gets their nth case before anyone gets their (n+1)th case.
	2. Desc by OrderQty: Everyone ordering m copies gets their nth case before 
		anyone ordering <m copies gets their nth case.
	*/---------------------------------------------------------------------------------
	,row_number() over(partition by ItemCode order by [Case],OrderQty desc,Loc)[AllocSeq]
into #SequencedSingleCaseOrders
from #SingleCaseOrders
order by ItemCode,Loc,AllocSeq


/*-----------------------------------------------------------------------
Combine the single copy/case orders back into totals by Location-Item,
up through however many copies we have available in inventory:
*/-----------------------------------------------------------------------
drop table if exists #InvAdjOrds
select ii.pfVendor
	,so.ItemCode
	,so.Loc
	,so.OrderQty[OrigLocOrdQ]
	,sum(case when so.AllocSeq*ii.CaseQty <= ii.WmsInvQ or 
                    (so.CaseQty * so.AllocSeq - ii.WmsInvQ >= 1 and so.CaseQty * so.AllocSeq - ii.WmsInvQ < so.CaseQty)
                then so.CaseQty
                else 0 end)[InvAdjLocOrdQ]
into #InvAdjOrds
from #SequencedSingleCaseOrders so
	inner join #ItemInventory ii on so.ItemCode = ii.ItemCode
group by ii.pfVendor
	,so.ItemCode
	,so.Loc
	,so.OrderQty




-- Loc-Item Order Details, incl Bottom-Fill Adjs to Oversolds----------
-----------------------------------------------------------------------
--     declare @UseSetID int = 19
select i.pfVendor
    ,isnull(ivo.InvConsq,'')[InvConsq]
	,o.Section
    ,ivo.aScheme[SecnSchID]
    ,sh.TOTAL_SCHEME_QTY[TotSchQ]
    ,o.RptIt
    ,i.ItemCode
    ,i.Title
    ,i.Cost[eaCost],i.Price[eaPrice]
    ,i.WmsInvQ,ivo.ChainInvQ,ivo.ChainRoS
	,o.Loc,o.aSchQty[LocSchQ]
    ,o.aRoS[LocRoS],o.aQoH[LocInvQ]
    ,o.OrderCat[LocOrdCat],o.OrderQty[OrigLocOrdQ]
	,isnull(a.InvAdjLocOrdQ,o.OrderQty)[InvAdjLocOrdQ]
    ,ivo.ItRnkInVndrByTotalLocs
    ,ivo.ItRnkInSecnByTotalLocs
    ,ivo.ItRnkInVndrByChainOrdQ
    ,ivo.ItRnkInSecnByChainOrdQ
    ,ivo.ItRnkInVndrByFpaFill
    ,ivo.ItRnkInSecnByFpaFill
from ReportsView..SuggOrds_OrigOrders o
	inner join #ItemInventory i on o.RptIt = i.RptIt
	left join #InvAdjOrds a on i.itemcode = a.itemcode and o.Loc = a.Loc
    left join #InvOrds ivo on i.ItemCode = ivo.ItemCode
    left join WMS_ILS..HPB_SCHEME_HEADER sh 
        on ivo.aScheme = sh.SCHEME_ID collate database_default
where o.SetID = @UseSetID
    -- and o.RptIt = '00000000000002002137'
	-- and i.pfVendor not in ('TEXASBKMNA')
order by i.pfVendor
    ,ivo.InvConsq desc
	,i.ItemCode
	,o.Loc

-- Item Totals---------
-----------------------
select ivo.pfVendor,ivo.InvConsq
    ,ivo.Section
    ,ivo.aScheme[SecnSchID]
    ,sh.TOTAL_SCHEME_QTY[TotSchQ]
    ,ivo.RptIt,ivo.ItemCode,ivo.Title
    ,ivo.eaCost,ivo.eaPrice
    ,ivo.WmsInvQ,ivo.ChainInvQ,ivo.ChainRoS
    ,ivo.TotalLocs
    ,ivo.LocsWithInv,ivo.LocsWithOrd
    ,ivo.ChainOrdQ[OrigChainOrdQ]
    ,ivo.ChainOrdC[OrigChainOrdC]
    ,ivo.InvAdjChainOrdQ
    ,ivo.InvAdjChainOrdC
    ,ivo.RemWmsInvQ,ivo.RemWmsInvC
    ,ivo.WmsFpaInvQ
    ,ivo.FpaFill,ivo.PctFpa
    ,ivo.ItRnkInVndrByTotalLocs
    ,ivo.ItRnkInSecnByTotalLocs
    ,ivo.ItRnkInVndrByChainOrdQ
    ,ivo.ItRnkInSecnByChainOrdQ
    ,ivo.ItRnkInVndrByFpaFill
    ,ivo.ItRnkInSecnByFpaFill
from #InvOrds ivo
    left join WMS_ILS..HPB_SCHEME_HEADER sh 
        on ivo.aScheme = sh.SCHEME_ID collate database_default
-- where --pfVendor not in ('TEXASBKMNA')
 order by pfVendor
    ,InvConsq desc
    ,ItemCode



/*--Temp Table cleanup on Aisle 5------------------------------------
drop table if exists #OrdsImport
drop table if exists #ItemInventory
drop table if exists #Orders
drop table if exists #SingleCaseOrders
drop table if exists #SequencedSingleCaseOrders
*/-------------------------------------------------------------------
