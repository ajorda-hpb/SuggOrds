
-- Centralized table for parameters used in suggested orders-----------------
-----------------------------------------------------------------------------
-- 7/7/20: First draft, need to review structure as there's patchy symmetries
-- e.g. SS has its own DaysInvOrd, BJ2, where QS & RS share DaysInvOrd. Should
-- SS share too? Should each Category have its own? Questions like that.
-- 7/11/20: Second draft, took BackoutDays out since it varies by location.
-- Also, renamed DaysAtLoc to MinDaysAtLoc, to better reflect its meaning.
-- And changed BJ2 to DaysInvOrdSS, to reflct any meaning whatsoever.

-- Table of Parameters, so I'm not having to change @params all over---------
-----------------------------------------------------------------------------
drop table if exists ReportsView.dbo.SuggOrds_Params
create table ReportsView.dbo.SuggOrds_Params(
	SetID int not null identity primary key
	,SetDescr varchar(100) not null 
	,RunDt date  not null --cell D2, day suggestions are calculated.
	,TitleCap int not null --cell F2, cap on number of title to suggest
	,RoundMethod int  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,minPctSld numeric(19,8) not null --cell K2
	,OrdFreq int not null --cell O2
	,minChPctNM numeric(19,8)  not null --cell V2
	,minLocPctNM numeric(19,8) not null  --cell W2
	,minZPctNM int not null  --cell X2
	,MinPctSldQS numeric(19,8) not null --cell AC2
	,DaysInvOrd int not null  --cell AE2, aka DaysInventory, used by QS & RS
	,MinDaysAtLoc int not null  --cell AI2, min days item can be in inventory at Loc
	,maxZRoS int not null   --cell AK2, upper limit on Loc RoS z-score 
	,[6moForQS] int not null    --cell AQ2, CALL THIS SOMETHING ELSE. Unbracketed [6moForQS] reads as a scalar 6 with header 'moForQS'
	,SalesForQS varchar(10) not null  --cell AW2, set to 'cur' or 'prj'
	,ProdCmp varchar(5) not null  --cell BF2, company being calculated
	,ShelfCopies int not null  --cell BK2, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,DaysInvOrdSS int not null  --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,StackCap int not null  --cell BM2
	,KeepOnHand int not null --cell SuggestedOrder!Q1, mostly for Crown Point & possibly other permanent displays. Mostly stays at zero
	,ShelfTitleCap int not null --cell SuggestedOrder!O1, currently unused but available should shelf title suggestions be capped.
	-- BackoutDays is now defined in LocParams as it differs by Location.
	-- ,BackoutDays int not null  --cell SuggestedOrder!F1, Days Transit Time BY LOCATION
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Initial parameter settings copied from Excel'
	,'7/1/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,30 --cell O2, OrdFreq
	,0.9  --cell V2, minChPctNM
	,0.9  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 4 parameter settings copied from Excel'
	,'7/31/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq
	,0.9  --cell V2, minChPctNM
	,0.9  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Eurographics settings circa Round 4'
	,'8/11/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.8 --cell K2, minPctSld
	,42 --cell O2, OrdFreq
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,2  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 5 parameter settings copied from Excel'
	,'8/26/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.9  --cell V2, minChPctNM
	,0.9  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Sales CS Tomfoolery & precursor to CAT 5'
	,'9/1/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.5 --cell K2, minPctSld
	,75 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,75 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,16  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,75 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,16  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 7 parameter settings copied from Excel'
	,'10/8/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 8 parameter settings copied from last round & call with Garren'
	,'10/30/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'HRO parameter settings for IDCROWNPOI'
	,'11/5/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.5 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, Days Inventory to order / project sales, used by SS
	,100  --cell BM2, StackCap
	,1   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'HRO parameter settings for IDCROWNB&C'
	,'11/5/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.5 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, Days Inventory to order / project sales, used by SS
	,100  --cell BM2, StackCap
	,1   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,48 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 9 parameter settings copied from last round, round 8'
	,'10/30/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Round 10, aka 2020 Wk52 Cycle, parameter settings copied from previous round'
	,'12/2/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk02 Cycle, parameter settings copied from previous round'
	,'12/30/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'same as 2021 Wk02 Cycle, but has ProdComp = aTTB to grab suggestions for out of stock product'
	,'12/30/20' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'aTTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk05 Cycle, parameter settings copied from previous round'
	,'1/20/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk08 Cycle, parameter settings copied from previous round'
	,'2/12/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'Logic fix: removed AvailWMS criteria from OrigSuggs creation'
	,'2/12/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk11 Cycle, parameter settings copied from previous round'
	,'3/2/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk14 Cycle, parameter settings copied from previous round'
	,'3/23/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk17 Cycle, parameter settings copied from previous round'
	,'4/13/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk20 Cycle, parameter settings copied from previous round'
	,'5/3/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk23 Cycle, parameter settings copied from previous round'
	,'5/24/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'RERUN 2021 Wk23 Cycle, parameter settings copied from previous round'
	,'5/24/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk26 Cycle, parameter settings copied from previous round'
	,'6/14/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk29 Cycle, parameter settings copied from previous round'
	,'7/6/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk32 Cycle, TTBs in-stock'
	,'7/26/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk32 Cycle, 180 Day TTB Out of Stocks'
	,'7/26/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk32 Cycle, 90 Day TTB Out of Stocks'
	,'7/26/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk35 Cycle, 180 Day TTB Out of Stocks'
	,'8/16/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk35 Cycle, 90 Day TTB Out of Stocks'
	,'8/16/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk35 Cycle, TTBs in-stock'
	,'8/16/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk35 Cycle, RERUN In-Stocks for 180 Day'
	,'8/16/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk38 Cycle, 180 Day TTB Out of Stocks'
	,'9/9/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk38 Cycle, 90 Day TTB Out of Stocks'
	,'9/9/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk38 Cycle, TTBs in-stock'
	,'9/9/21' --cell D2, RunDt, day suggestions are calculated.
	,1000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk38 Cycle, RERUN In-Stocks for 180 Day'
	,'9/9/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk42 Cycle, 180 Day TTB Out of Stocks'
	,'10/4/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk42 Cycle, 180 Day TTB In-Stock'
	,'10/4/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk42 Cycle, 90 Day TTB Out of Stocks'
	,'10/4/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk46 Cycle, 90 Day TTB In-Stock'
	,'11/1/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk46 Cycle, 180 Day TTB In-Stock'
	,'11/1/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'TTB Purchase Ordering - 1yr Arcturus & Flame Tree'
	,'11/3/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,180 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,365 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,365 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'TTB Purchase Ordering - 6mo Arcturus & Flame Tree'
	,'11/4/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,90 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk50 Cycle, 90 Day TTB In-Stock'
	,'12/7/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2021 Wk50 Cycle, 180 Day TTB In-Stock'
	,'12/7/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2022 Wk01 Cycle, 90 Day TTB In-Stock'
	,'12/20/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2022 Wk01 Cycle, 180 Day TTB In-Stock'
	,'12/20/21' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'HRO Purchase Ordering - 1yr IDEUROGRA & IDBOOKDEPO'
	,'1/3/2022' --cell D2, RunDt, day BaseData was calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,180 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,365 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,365 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'HRO Purchase Ordering - 6mo IDEUROGRA & IDBOOKDEPO'
	,'1/3/2022' --cell D2, RunDt, day BaseData was calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,90 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'HPB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'TTB Purchase Ordering - 1yr Arc&FT&Picc'
	,'1/3/2022' --cell D2, RunDt, day BaseData was calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,180 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,365 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,365 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'TTB Purchase Ordering - 6mo Arc&FT&Picc'
	,'1/3/2022' --cell D2, RunDt, day BaseData was calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,90 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,180 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,80000  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,180 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,80000  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

insert into ReportsView.dbo.SuggOrds_Params
values (
	'2022 Wk07 Cycle, 90 Day TTB In-Stock'
	,'2/2/2022' --cell D2, RunDt, day suggestions are calculated.
	,1000000 --cell F2, TitleCap, cap on number of title to suggest
	,0  --cell H2, Rounding Method: -1= round down, 0= round, 1= round up
	,0.9 --cell K2, minPctSld
	,42 --cell O2, OrdFreq, Days Order Frequency
	,0.8  --cell V2, minChPctNM
	,0.8  --cell W2, minLocPctNM
	,-2 --cell X2, minZPctNM
	,0.5 --cell AC2, MinPctSldQS
	,90 --cell AE2, DaysInvOrd, named range DaysInventory, used by QS & RS
	,31 --cell AI2, DaysAtLoc, min days item can be in inventory at Loc
	,4  --cell AK2, upper limit on Loc RoS z-score 
	,8  --cell AQ2, 6moForQS
	,'prj' --cell AW2, SalesForQS, alternately can be set to 'cur'
	,'TTB' --cell BF2, ProdCmp, company being calculated
	,-1 --cell BK2, ShelfCopies, 0 copies/title = 0; 1 copy/title = 1, n copies/title = -1
	,90 --cell BJ2, BJ2, Days Inventory to order / project sales, used by SS
	,8  --cell BM2, StackCap
	,0   --cell SuggestedOrder!Q1, KeepOnHand: 0 = NO; 1 = YES
	,1000000 --cell SuggestedOrder!O1, ShelfTitleCap
)

select * from ReportsView..SuggOrds_Params order by SetID desc

