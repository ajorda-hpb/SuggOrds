
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

select * from ReportsView..SuggOrds_Params order by SetID desc




drop table if exists ReportsView.dbo.SuggOrds_LocParams

create table ReportsView.dbo.SuggOrds_LocParams(
	ToLoc varchar(20) not null
	,FromLoc varchar(20) not null
	,BackoutDays int not null
	,PrevClosed int not null  --cell Z2, was Y/N with a Y just for 067.
	,constraint pk_SuggOrdsLocParams primary key(ToLoc,FromLoc)
)

insert into ReportsView.dbo.SuggOrds_LocParams
values 
	('00001','00944',20,0),('00002','00944',21,0),('00003','00944',22,0),('00004','00944',28,0),('00005','00944',30,0),('00006','00944',32,0),('00007','00944',30,0)
	,('00008','00944',23,0),('00009','00944',32,0),('00010','00944',28,0),('00011','00944',33,0),('00012','00944',21,0),('00013','00944',30,0),('00014','00944',35,0)
	,('00015','00944',38,0),('00016','00944',22,0),('00017','00944',30,0),('00018','00944',22,0),('00019','00944',30,0),('00021','00944',32,0),('00022','00944',34,0)
	,('00023','00944',34,0),('00024','00944',33,0),('00025','00944',28,0),('00026','00944',34,0),('00029','00944',28,0),('00030','00944',30,0),('00031','00944',35,0)
	,('00032','00944',31,0),('00033','00944',22,0),('00034','00944',34,0),('00035','00944',35,0),('00036','00944',34,0),('00037','00944',35,0),('00038','00944',39,0)
	,('00039','00944',39,0),('00040','00944',30,0),('00041','00944',35,0),('00043','00944',23,0),('00044','00944',32,0),('00045','00944',31,0),('00046','00944',21,0)
	,('00047','00944',39,0),('00048','00944',34,0),('00049','00944',23,0),('00050','00944',38,0),('00051','00944',35,0),('00052','00944',29,0),('00053','00944',34,0)
	,('00054','00944',34,0),('00055','00944',35,0),('00056','00944',32,0),('00057','00944',30,0),('00058','00944',21,0),('00059','00944',23,0),('00061','00944',38,0)
	,('00062','00944',38,0),('00064','00944',34,0),('00065','00944',21,0),('00066','00944',38,0),('00067','00944',35,1),('00068','00944',34,0),('00069','00944',37,0)
	,('00070','00944',23,0),('00071','00944',34,0),('00072','00944',37,0),('00073','00944',23,0),('00074','00944',33,0),('00075','00944',30,0),('00076','00944',30,0)
	,('00077','00944',38,0),('00078','00944',23,0),('00080','00944',31,0),('00081','00944',21,0),('00082','00944',29,0),('00083','00944',22,0),('00084','00944',23,0)
	,('00085','00944',23,0),('00086','00944',35,0),('00087','00944',34,0),('00088','00944',30,0),('00090','00944',34,0),('00091','00944',29,0),('00094','00944',34,0)
	,('00095','00944',33,0),('00096','00944',34,0),('00097','00944',30,0),('00098','00944',22,0),('00099','00944',35,0),('00100','00944',39,0),('00102','00944',40,0)
	,('00103','00944',38,0),('00104','00944',30,0),('00105','00944',22,0),('00106','00944',37,0),('00107','00944',30,0),('00108','00944',34,0),('00109','00944',23,0)
	,('00110','00944',22,0),('00111','00944',22,0),('00112','00944',35,0),('00113','00944',28,0),('00114','00944',22,0),('00115','00944',34,0),('00116','00944',30,0)
	,('00117','00944',34,0),('00118','00944',30,0),('00119','00944',34,0),('00120','00944',39,0),('00121','00944',30,0),('00122','00944',35,0),('00123','00944',39,0)
	,('00124','00944',34,0),('00125','00944',45,0),('00126','00944',45,0),('00127','00944',39,0),('00128','00944',34,0),('00129','00944',29,0),('00130','00944',23,0)
	,('00131','00944',40,0),('00132','00944',60,0),('00133','00944',35,0)
	-- For any vendors (or other sources) that send to the CDC...
	,('all','IDCROWNPOI',21,0),('all','IDCROWNB&C',21,0)

	/*-- Orig set from when we still ran weekly shipments...
	('00001',21),('00002',21),('00003',21),('00004',21),('00005',21),('00006',28),('00007',21),('00008',21),('00009',28),('00010',21)
	,('00011',28),('00012',21),('00013',35),('00014',28),('00015',28),('00016',21),('00017',21),('00018',21),('00019',35),('00021',28)
	,('00022',42),('00023',42),('00024',28),('00025',21),('00026',42),('00029',21),('00030',35),('00031',35),('00032',35),('00033',21)
	,('00034',42),('00035',28),('00036',42),('00037',42),('00038',28),('00039',28),('00040',35),('00041',28),('00043',21),('00044',28)
	,('00045',35),('00046',21),('00047',28),('00048',42),('00049',21),('00050',35),('00051',28),('00052',35),('00053',42),('00054',42)
	,('00055',42),('00056',28),('00057',21),('00058',21),('00059',21),('00061',35),('00062',35),('00064',42),('00065',21),('00066',35)
	,('00067',42),('00068',42),('00069',42),('00070',42),('00071',42),('00072',42),('00073',42),('00074',28),('00075',21),('00076',21)
	,('00077',35),('00078',42),('00080',35),('00081',21),('00082',35),('00083',21),('00084',42),('00085',21),('00086',35),('00087',28)
	,('00088',35),('00090',28),('00091',35),('00094',28),('00095',28),('00096',42),('00097',35),('00098',21),('00099',35),('00100',28)
	,('00102',28),('00103',28),('00104',21),('00105',28),('00106',28),('00107',35),('00108',28),('00109',21),('00110',28),('00111',21)
	,('00112',42),('00113',21),('00114',28),('00115',28),('00116',35),('00117',28),('00118',21),('00119',28),('00120',35),('00121',35)
	,('00122',42),('00123',35),('00124',28),('00125',28),('00126',28),('00127',35),('00128',28),('00129',35),('00130',42),('00131',28)
	,('00132',28),('00133',35)    
	-- Before adding to/from location distinctions...
	,('00001',20,0),('00002',21,0),('00003',22,0),('00004',28,0),('00005',30,0),('00006',32,0),('00007',30,0),('00008',23,0),('00009',32,0),('00010',28,0)
	,('00011',33,0),('00012',21,0),('00013',30,0),('00014',35,0),('00015',38,0),('00016',22,0),('00017',30,0),('00018',22,0),('00019',30,0),('00021',32,0)
	,('00022',34,0),('00023',34,0),('00024',33,0),('00025',28,0),('00026',34,0),('00029',28,0),('00030',30,0),('00031',35,0),('00032',31,0),('00033',22,0)
	,('00034',34,0),('00035',35,0),('00036',34,0),('00037',35,0),('00038',39,0),('00039',39,0),('00040',30,0),('00041',35,0),('00043',23,0),('00044',32,0)
	,('00045',31,0),('00046',21,0),('00047',39,0),('00048',34,0),('00049',23,0),('00050',38,0),('00051',35,0),('00052',29,0),('00053',34,0),('00054',34,0)
	,('00055',35,0),('00056',32,0),('00057',30,0),('00058',21,0),('00059',23,0),('00061',38,0),('00062',38,0),('00064',34,0),('00065',21,0),('00066',38,0)
	,('00067',35,1),('00068',34,0),('00069',37,0),('00070',23,0),('00071',34,0),('00072',37,0),('00073',23,0),('00074',33,0),('00075',30,0),('00076',30,0)
	,('00077',38,0),('00078',23,0),('00080',31,0),('00081',21,0),('00082',29,0),('00083',22,0),('00084',23,0),('00085',23,0),('00086',35,0),('00087',34,0)
	,('00088',30,0),('00090',34,0),('00091',29,0),('00094',34,0),('00095',33,0),('00096',34,0),('00097',30,0),('00098',22,0),('00099',35,0),('00100',39,0)
	,('00102',40,0),('00103',38,0),('00104',30,0),('00105',22,0),('00107',30,0),('00108',34,0),('00109',23,0),('00110',22,0),('00111',22,0),('00112',35,0)
	,('00113',28,0),('00114',22,0),('00115',34,0),('00116',30,0),('00117',34,0),('00118',30,0),('00119',34,0),('00120',39,0),('00121',30,0),('00122',35,0)
	,('00123',39,0),('00124',34,0),('00125',45,0),('00126',45,0),('00127',39,0),('00128',34,0),('00129',29,0),('00130',23,0),('00131',40,0),('00132',60,0)
	,('00133',35,0)     */
	



select * from ReportsView..SuggOrds_LocParams