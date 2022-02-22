 
--  Create SuggOrds_OrigOrders table holding initial suggestions of any/all items for which we have sales data
--------------------------------------------------------------------------------------------------------------
-- 10/14/20: Original file created, trimmed down from SuggOrds_ItemClassification 20200629.sql
-- 11/19/20: Removed stores 11 & 52 from suggestions. Ran for Round 9, aka the Wk49 cycle.
-- 12/02/20: Added records for stores with inventory, but zero suggestions
-- 12/30/20: Thinking about how to capture TTB stuff we should maybe buy again, but is currently at AvailWMS = 0
-- 02/18/21: Removed all AvailWMS > 0 tests AFTER the one used for paring down the RptIt list at the begining.
-- 			 & refactored joins on SuggOrds_LocParams to reflect new structure specifying ToLoc & FromLoc.
-- 08/04/21: Added @runOutOfStocks variable to run In-Stock (setID > 0) or Out-of-Stock (setID < 0) suggestions.
-- 			 & added the ItemCatRnk field to the SuggOrds_OrigOrds table
-- 12/07/21: Added store 056 to list of stores to exclude cos they're closing :(  
/*
-- See how it's going...
select SetID,OrderUse,CreateDt,count(*),sum(OrderQty)[TotOrdQ]
from ReportsView.dbo.SuggOrds_OrigOrders
group by SetID,OrderUse,CreateDt
order by SetID

-- Or undo a thing...
delete oo
from ReportsView.dbo.SuggOrds_OrigOrders oo
where setID = 41
*/

 use ReportsView 

-- Which set of items are orders being generated for?------------------------
-----------------------------------------------------------------------------
-- set 12 reflects round 11 params, runDt = 12/30/2020
-- set 13 is the same thing, but runs 'HPB' for ProdCmp to NOT exclude stuff that's out of stock
-- set 15 is for the 2021 Wk08 TTB Cycle
-- ...lots more sets...
-- set 21 is for rerun of 2021 Wk23 TTB Cycle, without all the checks for AvailWMS > 0


-- select * from ReportsView..SuggOrds_Params order by SetID desc

declare @UseSetID int = (select max(SetID) from ReportsView..SuggOrds_OrigOrders)   --51  --
declare @runOutOfStocks bit = 0
declare @OrderUse varchar(100) = (select SetDescr from ReportsView..SuggOrds_Params where setID = @UseSetID)

-- !! To run suggestions on Out of Stocks, uncomment the below...
-- set @runOutOfStocks = 1

drop table if exists #OrdItems
create table #OrdItems(RptIt varchar(20), OrderUse varchar(100))

-- Runs Active & In-Stock items-----------------------
if isnull(@runOutOfStocks,0) = 0 
begin
	insert into #OrdItems
	select ie.RptIt
		,@OrderUse[OrderUse]
	from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
		inner join ReportsView..vw_DistributionProductMaster pm on pm.ItemCode = ie.RptIt
	where ie.PurchaseFromVendorID in ('TEXASBKMNA','TEXASSTATI','TEXASBKMNB','TEXASBKNON','TEXASBKPUZ','TEXASBKUPC')
	group by ie.RptIt
	having max(Rord) = 'YY' or sum(ie.AvailWMS) > 0
end

-- Runs Out of Stock items----------------------------
if isnull(@runOutOfStocks,0) = 1 
begin
	insert into #OrdItems
	select ie.RptIt
		,@OrderUse[OrderUse]
	from ReportsView..SuggOrds_ItemEquivs ie with(nolock)
	where ie.PurchaseFromVendorID in ('TEXASBKMNA','TEXASSTATI','TEXASBKMNB','TEXASBKNON','TEXASBKPUZ','TEXASBKUPC') 
	group by ie.RptIt
	having max(Rord) <> 'YY' and sum(ie.AvailWMS) = 0
end

-- Which set of params is being used?----------------------------------------
-----------------------------------------------------------------------------
drop table if exists #params
select * 
    ,@OrderUse[OrderUse]
into #params   --   select *
from ReportsView.dbo.SuggOrds_Params
where setID = @UseSetID


-- Scheme Details & Section-based Scheme Assignments-------------------------
-----------------------------------------------------------------------------
drop table if exists #SchQs
select '00'+sd.STORE_ID collate database_default as Loc 
	,sd.Scheme_ID collate database_default as Scheme
	,cast(case  when sh.Scheme_Notes in ('R2','R4') then avg(sd.Scheme_Qty)
				when sh.Scheme_Notes = 'MVA' then sum(Scheme_Qty) 
				else max(sd.Scheme_Qty) end as numeric(10,5))[SchQty]
into #SchQs
from wms_ils..HPB_Scheme_Detail sd with(nolock)
	inner join wms_ils..HPB_Scheme_Header sh with(nolock)
		on sd.Scheme_ID collate database_default = sh.scheme_ID collate database_default 
where sd.STORE_ID < '200'
	and sd.STORE_ID not in ('011','020','027','028','042','052','056','060','063','079','089','092','093','101','106')
	and sh.SCHEME_TYPE = 'Standard'
group by '00'+sd.STORE_ID collate database_default 
	,sd.Scheme_ID collate database_default 
	,sh.Scheme_Notes


-- Create grid of all possible RptIt-Loc combinations------------------------
-- & calculate ADJUSTED RoS & QoH--------------------------------------------
-----------------------------------------------------------------------------
drop table if exists #RptItxLoc
select ie.RptIt
	,l.LocationNo[Loc]
	,sq.SchQty[aSchQty]
	,cast(null as numeric(27,21))[aRoS]
	,cast(null as numeric(27,21))[aQoH]
into #RptItxLoc
from ReportsView..SuggOrds_ItemEquivs ie
	cross join ReportsData..Locations l with(nolock)
	left join #SchQs sq on ie.aScheme = sq.Scheme and l.LocationNo = sq.Loc
    inner join #OrdItems it on ie.ItemCode = it.RptIt
where l.LocationNo < '00150' 
	and l.Status = 'A'
	and l.LocationNo not in ('00011','00020','00027','00028','00042','00052','00056','00060','00063','00079','00089','00092','00093','00101','00106')
group by ie.RptIt
	,l.LocationNo
	,sq.SchQty

-- Calculate Adjusted Rate of Sale (aRoS)------------------
update #RptItxLoc
set aRoS = case when PctSld is null then ie.avgRoS
				when (isnull(bd.TotInvDays,0) <= p.MinDaysAtLoc or (isnull(bd.QtyInb,0) <= isnull(tar.aSchQty,0))) 
						and isnull(bd.zRoS,0) >= p.maxZRoS 
					then (isnull(bd.RoS,0) + ie.avgRoS) / 2.0
				else bd.RoS end
from #RptItxLoc tar
	left join ReportsView..SuggOrds_BaseData bd
		on tar.Loc = bd.Loc and tar.RptIt = bd.RptIt
	inner join ReportsView..SuggOrds_ItemEquivs ie 
		on tar.RptIt = ie.ItemCode
    cross join #params p 

-- Calculate Adjusted Quantity on Hand (aQoH)--------------
update #RptItxLoc
set aQoH = dbo.maxof(0,isnull(bd.LGI,0) - tar.aRoS * lp.BackoutDays)
from #RptItxLoc tar
	inner join ReportsView..SuggOrds_LocParams lp with(nolock)
		on tar.Loc = lp.ToLoc and lp.FromLoc = '00944'
	left join ReportsView..SuggOrds_BaseData bd
		on tar.Loc = bd.Loc and tar.RptIt = bd.RptIt
    cross join #params p 


-- Categorize each RptIt at each Loc, NO/QS/RS/SS----------------------------
-----------------------------------------------------------------------------
drop table if exists #RoSCats
select rl.Loc
	,rl.RptIt
	,rl.aSchQty
	,rl.aRoS
	,rl.aQoH
	-- Never Ordered Criteria
	,case when ie.pctLocsSld < 1 
			and abs(datediff(DD,ie.avgRcvDt,p.RunDt)) > 30
			-- and (ie.AvailWMS > 0 or p.ProdCmp <> 'TTB')
			and ie.ChPctNM > p.minChPctNM 
			and ie.avgRoS * 180 > p.[6moForQS]
			-- !! This next one actually first appears in the initial suggestion, NOT in eligibility.
			-- !! It has major implications for  which titles get selected
			and bd.PctSld is null
		then 1 
        else 0 
        end[NO]

	-- Quick Seller Criteria
	,case when ((p.SalesForQS =  'prj' and bd.PctSld + (bd.LGI - rl.aQoH) * 1.0 / nullif(bd.QtyInb,0) > p.MinPctSldQS)
					or (p.SalesForQS <> 'prj' and bd.PctSld >= p.MinPctSldQS))
				-- and (ie.AvailWMS > 0 or p.ProdCmp <> 'TTB')
				and bd.PctSld is not null
				-- p.DNMOC expanded...
				and (case when (rl.aQoH/nullif(QtyInb,0) - (1.0 - p.minPctSld) > 0 and rl.aQoH - (rl.aRoS * p.OrdFreq * 1.5) >= 0)
							or (ie.ChPctNM <  p.minChPctNM and bd.PctNM <  p.minLocPctNM)
							or (ie.ChPctNM >= p.minChPctNM and bd.PctNM <= p.minLocPctNM and bd.zPctNM >= p.minZPctNM)
						then 1 else 0 end) = 0
				-- Redundant with logic in DNMOC. Also the zero overlaps.
				and rl.aQoH - rl.aRoS * p.OrdFreq * 1.5 < 0
				and ceiling(180 * rl.aRoS) >= p.[6moForQS]
		then 1 
        else 0 
        end[QS]

	-- Restock Criteria
	,case when bd.PctSld is null
			or rl.aRos < 1.0/p.DaysInvOrd
			-- or (ie.AvailWMS = 0 and p.ProdCmp = 'TTB')
			or rl.aQoH >= rl.aRoS * p.OrdFreq * 1.5
			-- Test for nonzero sQS happens here, but it doesn't exist yet.
			-- Could instead test for QS eligibility in an update, 
			-- so it's not a big ugly copypasta of the above.
			-- With the caveat that stuff DOESN'T get suggested when QS = 1 BUT sQS = 0,
			-- which happens when either...
			-- 	bd.LGI > dbo.minof(2.0 * isnull(bd.SoldQty,0),bd.QtyInb) and bd.TotInvDays < p.MinDaysAtLoc
			-- 	bd.aQoH > dbo.minof(2 * bd.SoldQty + bd.aRoS * p.BackoutDays, bd.aRoS * p.DaysInvOrd) and bd.TotInvDays >= p.MinDaysAtLoc
			-- But really the question: is either of the above incompatible with RS to begin with? If so, testing against QS is sufficient 
		then 0 
		when (bd.PctSld >= p.minPctSld or lp.PrevClosed = 1)
			and ((ie.ChPctNM >= p.minChPctNM and zPctNM <= p.minZPctNM)
				  or bd.PctNM >= p.minLocPctNM)
		then 1 
        else 0 
        end[RS]

	-- Shelf Seller Criteria
	,case when rl.aQoH > 0 
			-- or (ie.AvailWMS = 0 and p.ProdCmp = 'TTB')
			or p.ShelfCopies = 0
		then 0 
		when bd.PctSld is not null
			and (bd.PctSld >= p.minPctSld or lp.PrevClosed = 1)
			and ((ie.ChPctNM >= p.minChPctNM and bd.zPctNM <= p.minZPctNM)
				  or bd.PctNM >= p.minLocPctNM)
		then 1 
        else 0 
        end[SS]
into #RosCats
from #RptItxLoc rl
	left join ReportsView..SuggOrds_BaseData bd with(nolock)
		on rl.Loc = bd.Loc and rl.RptIt = bd.RptIt 
	inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
		on rl.RptIt = ie.ItemCode
	inner join ReportsView..SuggOrds_LocParams lp with(nolock)
		on rl.Loc = lp.ToLoc and lp.FromLoc = '00944'
    cross join #params p 

-- Updating #RosCats to handle exclusions based on higher priority categories (NO > QS > RS > SS)
---------------------------------------------------------------------
update #RosCats
set RS = case when QS = 1 
                then 0 
                else RS 
                end
	--  RS not included below cos workbook only tests for fRS, which doesn't yet exist
	,SS = case when 1 in (NO, QS) 
                then 0 
                else SS 
                end
from #RosCats


-- Baseline Suggestions & RoS Ranks-----------------------------
----------------------------------------------------------------
drop table if exists #BaseSuggs
select rc.*
	-- Never Ordered suggestion
	,case when rc.NO = 1 
			-- and ie.AvailWMS > 0 
			-- !! WHY is this not in the eligibility test?!
			-- and bd.PctSld is null 
		then dbo.maxof(dbo.maxof(1,isnull(rc.aSchQty,0)) - rc.aQoH,0)
		else 0 
        end[sNO]

	-- Quick Seller suggestion
	,case when rc.QS = 1 
				-- and ie.AvailWMS > 0 
		then case when bd.TotInvDays < p.MinDaysAtLoc 
				then dbo.maxof(0, dbo.minof(2.0 * isnull(bd.SoldQty,0),bd.QtyInb) - bd.LGI)
				else dbo.maxof(0, dbo.minof(2.0 * (bd.SoldQty + rc.aRoS * lp.BackOutDays), 
											rc.aRoS * p.DaysInvOrd) - rc.aQoH) 
                end
		else 0 
        end[sQS]

	-- Restock suggestion
	,case when rc.RS = 1 
			-- and ie.AvailWMS > 0 
		then dbo.maxof(1.0, dbo.minof(2 * bd.SoldQty, rc.aRoS * p.DaysInvOrd)) - rc.aQoH
		else 0 
        end[sRS]

	-- Shelf Seller suggestion
	,case when rc.SS = 1 
			-- and ie.AvailWMS > 0 
		then case p.ShelfCopies 
				when -1 then round(rc.aRoS * p.DaysInvOrdSS,0) 
				when  1 then 1 
				-- Technically redundant since p.ShelfCopies = 0 is checked in SS.
				else  0 
                end 
		else 0 
        end[sSS]

	,cast(null as int)[rnkNO]
	,cast(null as int)[rnkQS]
	,cast(null as int)[rnkRS]
	,cast(null as int)[rnkSS]
	,cast(null as float)[limNO]
	,cast(null as float)[limQS]
	,cast(null as float)[limRS]
	,cast(null as float)[limSS]
	,cast(null as float)[fsNO]
	,cast(null as float)[fsQS]
	,cast(null as float)[fsRS]
	,cast(null as float)[fsSS]
into #BaseSuggs
from #RosCats rc 
	left join ReportsView..SuggOrds_BaseData bd with(nolock) 
		on bd.Loc = rc.Loc and bd.RptIt = rc.RptIt
	inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
		on rc.RptIt = ie.ItemCode
	inner join ReportsView..SuggOrds_LocParams lp with(nolock)
		on rc.Loc = lp.ToLoc and lp.FromLoc = '00944'
    cross join #params p 

-- Add item rankings to #BaseSuggs------------------------------
----------------------------------------------------------------
;with ranks as(
	select Loc,RptIt
	-- With the exception of NO, all subsequent categories are only ranked if they have 
	-- a nonzero SUGGESTION, NOT on whether or not they're just eligible.
	,case when bs.sNO > 0 --and ie.AvailWMS > 0 
		then row_number() over(partition by bs.Loc,sign(bs.sNO) order by bs.aRoS desc) 
        end[rnkNO]

	,case when bs.sQS > 0 --and ie.AvailWMS > 0 
		then row_number() over(partition by bs.Loc,sign(bs.sQS) order by bs.aRoS desc) 
        end[rnkQS]

	,case when bs.sRS > 0 --and ie.AvailWMS > 0 
		then row_number() over(partition by bs.Loc,sign(bs.sRS) order by bs.aRoS desc) 
        end[rnkRS]

	,case when bs.sSS > 0 --and ie.AvailWMS > 0 
		then row_number() over(partition by bs.Loc,sign(bs.sSS) order by bs.aRoS desc) 
        end[rnkSS]

	from #BaseSuggs bs
)
update #BaseSuggs
set rnkNO = r.rnkNo
	,rnkQS = r.rnkQS
	,rnkRS = r.rnkRS
	,rnkSS = r.rnkSS
from #BaseSuggs bs inner join ranks r 
	on bs.Loc = r.Loc and bs.RptIt = r.RptIt

-- Limit # of Suggestions based on Item's aRoS Rank-------------------
----------------------------------------------------------------------
;with RnkCounts as(
	select Loc
		,count(case when rnkNO > 0 then RptIt end)numNO
		,count(case when rnkQS > 0 then RptIt end)numQS
		,count(case when rnkRS > 0 then RptIt end)numRS
		,count(case when rnkSS > 0 then RptIt end)numSS
	from #BaseSuggs group by Loc
)
update #BaseSuggs
	set limNO = case when rnkNO <= p.TitleCap then sNO 
                        else 0 
                        end
		,fsNO = case when rnkNO <= p.TitleCap then sNO 
                        else 0 
                        end

		,limQS = case when rnkQS <= p.TitleCap - rc.numNO then
					case when sQS + aQoH > p.StackCap then
						 dbo.minof(dbo.maxof(p.StackCap - bs.aQoH
						 					-- The excel equiv for this line calcs to 7.00000000006599floatingbullshit, which then evals to 8 >.<
											-- Nested cast inside the ceiling function to get rid of bullshit .000000000000000000001's rounding UP to the next integer.
											,ceiling(cast(bs.aRoS * 1.5 * p.OrdFreq - bs.aQoH as numeric(22,15))))
									,bs.sQS)
						else sQS 
                        end
					else 0 
                    end
					
		,limRS = case when round(aQoH + sRS,0) <= 2 then 0    -- This kicks the suggestion down into the Shelf Sellers category
					when rnkRS <= p.TitleCap - rc.NumNO - rc.numQS then sRS
					else 0 
                    end

		,limSS = case when rnkSS <= p.TitleCap - rc.NumNO - rc.numQS - rc.numRS 
						then dbo.maxof(0, floor(p.DaysInvOrdSS * aRoS) - aQoH)
					else 0 
                    end
from #BaseSuggs bs
	inner join RnkCounts rc on bs.Loc = rc.Loc
    cross join #params p 

-- Final Suggestion Adjustments based on ?!?!?------------------------
----------------------------------------------------------------------
update #BaseSuggs
	set fsQS = 
		dbo.minof(limQS, 
			case when bd.TotInvDays < p.MinDaysAtLoc then sQS 
				else (case when limQS > 0
							and ie.Price >= 19.99 
							and bs.aQoH > 0 
							and bd.SoldQty < bd.QtyInb then dbo.minof(bs.aSchQty, 2) 
						else (case when limQS > p.StackCap then ceiling(dbo.maxof(bs.aRoS * 1.5 * p.OrdFreq - bs.aQoH, p.StackCap)) 
							-- Replaced below as workaround for Excel's rounding bullshit
									else (case when round(limQS + bs.aQoH,0) - bs.aRoS * p.DaysInvOrd > 0.0000001 then floor(limQS) 
											else limQS 
                                            end)
									end)
						end)
				end)
	-- Old Version
	-- ,fsRS = case when limRS > 0
	-- 				and ie.Price >= 19.99 
	-- 				and RS = 1
	-- 				and bd.SoldQty < QtyInb then dbo.minof(bs.aSchQty, 2) 
	-- 			else (case when limRS > p.stackCap then 
	-- 					dbo.maxof(bs.aRoS * 1.5 * p.OrdFreq - bs.aQoH, p.StackCap)
	-- 					else limRS 
    --                     end)
	-- 			end
	--**Revised!! Copied over logic from fsQS-------------
	,fsRS = 
		dbo.minof(limRS, 
			case when bd.TotInvDays < p.MinDaysAtLoc then sRS 
				else (case when limRS > 0
							and ie.Price >= 19.99 
							and bs.aQoH > 0 
							and bd.SoldQty < bd.QtyInb then dbo.minof(bs.aSchQty, 2) 
						else (case when limRS > p.StackCap then ceiling(dbo.maxof(bs.aRoS * 1.5 * p.OrdFreq - bs.aQoH, p.StackCap)) 
							-- Replaced below as workaround for Excel's rounding bullshit
									else (case when round(limRS + bs.aQoH,0) - bs.aRoS * p.DaysInvOrd > 0.0000001 then floor(limRS) 
											else limRS 
                                            end)
									end)
						end)
				end)
	,fsSS = limSS
from #BaseSuggs bs
	left join ReportsView..SuggOrds_BaseData bd with(nolock) 
		on bd.Loc = bs.Loc and bd.RptIt = bs.RptIt
	inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
		on bs.RptIt = ie.ItemCode
    cross join #params p 

-- omfg that ONE thing...
update #BaseSuggs
set limSS = 0
	,fsSS = 0
from #BaseSuggs
where fsRS > 0


-- Pare down orig Suggs to >0 only & price-based Adjs & overall title cap-----
------------------------------------------------------------------------------
drop table if exists #Ords
select bs.Loc
	,bs.RptIt
    ,bs.aSchQty
	,ie.Section
	,bs.aRoS,bs.aQoH
	,fsNO+fsQS+fsRS+fsSS[BaseSugg]

	,case when fsNO > 0 then 'NO'
			when fsQS > 0 then 'QS'
			when fsRS > 0 then 'RS' 
            else 'SS' 
            end[ItemCat]

	,case when fsNO > 0 then bs.rnkNO
			when fsQS > 0 then bs.rnkQS
			when fsRS > 0 then bs.rnkRS
            else bs.rnkSS
            end[ItemCatRnk]

	,case when 1 - (aQoH - aRoS * p.DaysInvOrd) > 0
				and p.KeepOnHand = 1
				and fsNO+fsQS+fsRS+fsSS < ie.CaseQty
				then ie.CaseQty
			when p.RoundMethod = 0    --ie 'Round'
				then round((fsNO+fsQS+fsRS+fsSS)/ie.CaseQty,0) * ie.CaseQty
			when (p.KeepOnHand = 1 and  1 - (aQoH - aRoS * p.DaysInvOrd) > 0)
				    or p.RoundMethod = 1  --ie 'RoundUp'
				then ceiling((fsNO+fsQS+fsRS+fsSS)/ie.CaseQty) * ie.CaseQty
			when p.RoundMethod = -1   --ie 'RoundDown'
				then floor((fsNO+fsQS+fsRS+fsSS)/ie.CaseQty) * ie.CaseQty
			else 0 
            end[PrelimOrd]

	,cast(null as numeric(20,8))[HardCapOrd]
	,cast(null as numeric(20,8))[FinalOrdQty]
into #Ords
from #BaseSuggs bs
	inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
	    on bs.RptIt = ie.ItemCode
    cross join #params p 
-- where fsNO+fsQS+fsRS+fsSS > 0
-- 	or aQoH > 0

update #Ords
set HardCapOrd = 
		case when ie.Price > 74.99 then 1
			when (right(ie.Scheme,2) = '-S'
					or ie.Scheme = 'Shelfx2'
					or ie.Price between 49.99 and 74.99)
				then dbo.maxof(ie.CaseQty,dbo.minof(2,bs.PrelimOrd))
			when ie.Price between 19.99 and 49.98
				then dbo.minof(bs.PrelimOrd,aRoS * 1.5 * p.OrdFreq)
			else bs.PrelimOrd 
            end
from #Ords bs
	inner join ReportsView..SuggOrds_ItemEquivs ie with(nolock)
	    on bs.RptIt = ie.RptIt
    cross join #params p 

-- Compare Location's shelf title counts to overall cap on shelf title count
;with ShelfRanks as(
	select Loc
		,RptIt
		,row_number() over(partition by Section,Loc order by HardCapOrd desc, aRoS desc)[ShelfRnk]
	from #Ords
	where ItemCat = 'SS'
)
update #Ords
set FinalOrdQty = 
	dbo.maxof(0,
		case when ItemCat <> 'SS' or (ItemCat = 'SS' and isnull(ShelfRnk,0) < p.ShelfTitleCap)
				then round(HardCapOrd,0)
			else 0 
            end)
from #Ords od left join ShelfRanks st 
	on od.RptIt = st.RptIt and od.Loc = st.Loc
    cross join #params p 

-- select * from #BaseSuggs where RptIt = '00000000000001901095' order by Loc
-- select * from #Ords where RptIt = '00000000000001901095' order by Loc
-- CREATE tables on Sage--------------------------
--------------------------------------------------
/* select count(*) from ReportsView.dbo.SuggOrds_OrigOrders

delete 
ReportsView.dbo.SuggOrds_OrigOrders
where SetID = 11

truncate table ReportsView.dbo.SuggOrds_OrigOrders

select * 
into #temp
from ReportsView.dbo.SuggOrds_OrigOrders

drop table if exists ReportsView.dbo.SuggOrds_OrigOrders
create table ReportsView.dbo.SuggOrds_OrigOrders(
	Loc char(5) not null
	,RptIt varchar(20) not null
	,Section varchar(10) null
	,aSchQty numeric(10, 5) null
	,aRoS numeric(27, 21) null
	,aQoH numeric(27, 21) null
	,OrderCat varchar(2) not null
	,ItemCatRnk int null
	,OrderQty numeric(20, 8) null
	,SetID int not null
	,RunDt date not null
    ,OrderUse varchar(50) not null
	,CreateDt datetime not null
) on [primary] 

insert into ReportsView.dbo.SuggOrds_OrigOrders(Loc,RptIt,Section,aSchQty,aRoS,aQoH,OrderCat,OrderQty,SetID,RunDt,OrderUse,CreateDt)
select *
from #temp 
where SetID <> 26

*/

insert into ReportsView.dbo.SuggOrds_OrigOrders
select bs.Loc
    ,bs.RptIt
    ,BS.Section
    ,bs.aSchQty
    ,bs.aRoS
    ,bs.aQoH
    ,bs.ItemCat[OrderCat]
	,bs.ItemCatRnk[ItemCatRnk]
    ,bs.FinalOrdQty[OrderQty]
    ,p.SetID
    ,p.RunDt
    ,p.OrderUse
    ,getdate()[CreateDt]
from #Ords bs cross join #params p



select count(*)[Count Here Matches Rows Inserted = WIN] 
from ReportsView.dbo.SuggOrds_OrigOrders
where SetID = @UseSetID



select setID,RunDt,OrderUse,CreateDt,count(*)[NumLines],sum(OrderQty)[TotOrdQty]
from ReportsView..SuggOrds_OrigOrders
group by setID,RunDt,OrderUse,CreateDt
order by 4 desc
