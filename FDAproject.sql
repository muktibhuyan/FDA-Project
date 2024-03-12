Use fda;
set session sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

###########################################################################################

#Task 1 : Identifying Approval Trends

create view Drug_approval AS
Select A.Applno,Sponsorapplicant,R.Actiontype,drugname,ActionDate,R.DocType,DocTypeDesc
 from application as A
Join product as P on P.ApplNo = A.ApplNo
Join regactiondate as R on P.ApplNo = R.ApplNo
join doctype_lookup as DL on DL.DocType = R.DocType;


SELECT * FROM Drug_approval;


#Query 1 : Determine the number of drugs approved each year and provide 
#insights into the yearly trends.

Select Extract(Year from ActionDate) as Action_Year,Actiontype,Count(*) as No_of_Approval
from Drug_Approval
group by Action_Year having Actiontype = 'AP'
order by Action_Year; 
 
 #Query 2 : Identify the top three years that got the highest and lowest approvals,
 #in descending and ascending order, respectively
 
 select Extract(Year from ActionDate) as Year,actiontype,count(actiontype) as Drugs_Count
 from Drug_approval 
 group by Year having actiontype = 'AP'
 ORDER BY Drugs_count DESC LIMIT 3;
 
SELECT 
    Extract(Year from ActionDate) as Year,
    actiontype,
    COUNT(actiontype) AS Drugs_Count
FROM
    Drug_approval
GROUP BY Year
HAVING actiontype = 'AP'
ORDER BY Drugs_count
LIMIT 3;
 
 #Query 3: Explore approval trends over the years based on sponsors.
 
 
SELECT 
    Sponsorapplicant AS Sponsors,
    Extract(Year from ActionDate) AS Year,Actiontype,
    Doctype,
    COUNT(*) AS Approved_Drugs_Count
FROM
    Drug_approval
    where Actiontype = 'AP' and doctype != 'TA'
GROUP BY Sponsors,Year
order by Sponsors,Year;


#Query 4: Rank sponsors based on the total number of approvals they received 
#each year between 1939 and 1960.

  SELECT 
  Sponsors,
	Approval_Year,Approvals_Total,
   RANK() OVER(partition by Approval_Year order by Approvals_Total DESC) AS Sponsors_Rank
   FROM(
   Select 
    Sponsorapplicant as Sponsors,Extract(Year from ActionDate) as Approval_Year,
    Count(*) as Approvals_Total
    FROM
    Drug_approval
    where Actiontype = 'AP' AND Extract(Year from ActionDate) between 1930 and 1960
    Group by Approval_Year,Sponsors
    ) as Approved_Drugs_Count
    Order by Approval_Year,sponsors_rank;
   
######################################################################################
#TASK 2 : Segmentation Analysis Based on Drug MarketingStatus


create view Product_Mktstatus AS
Select P.Applno,P.ProductNo,P.ProductMktStatus,ActionDate,A.Actiontype
from Product as P
Join Product_TECode as PTE on PTE.ApplNo = P.ApplNo
Join Application as A on P.ApplNo = A.ApplNo
Join regactiondate as R on A.ApplNo = R.ApplNo;


# Query 1: Group products based on MarketingStatus.
# Provide meaningful insights into the segmentation patterns.


select
 ProductMktStatus,Productno,count(*) as Product_Count
from Product_MktStatus
group by Productno;


#Query 2: Calculate the total number of applications for each MarketingStatus year-wise
# after the year 2010.

select 
Productmktstatus,year(actiondate)as Approval_year,
Count(applno) as No_of_Applications
from product_mktstatus
where year(actiondate)>2010
group by productmktstatus,Approval_Year;

#Query 3 : Identify the top MarketingStatus with the maximum number of applications and 
#analyze its trend over time.

Select 
Marketstatus,Approval_year,
No_of_applications,
Rank()over(partition by Approval_year order by No_of_Applications desc) as Rank_productmkstatus
From
(Select 
    Productmktstatus as Marketstatus,Extract(Year from ActionDate) as Approval_Year,
    Count(applno) as No_of_applications
    FROM
    Product_mktstatus
     Group by Marketstatus,Approval_year
    ) as Product_MktST_Count
group by Marketstatus,Approval_year
order by no_of_Applications DESC ;
######################################################################################
#TASK 3 : Analyzing Products


create view Product_Dosageforms AS
Select P.Applno,P.ProductNo,P.ProductMktStatus,
concat(dosage,' ',form) as DosageForm,dosage,form,ActionDate,DocType
from Product as P
Join Application as A on P.ApplNo = A.ApplNo
Join regactiondate as R on A.ApplNo = R.ApplNo;


#Query 1 :Categorize Products by dosage form and analyze their distribution.



#Query 2: Calculate the total number of approvals for each dosage form and 
#identify the most successful forms.

Select
Dosageform,Count(*) as No_Of_Approvals
from product_dosageforms
group by Dosageform
order by No_of_Approvals DESC;


#Query 3 : Investigate yearly trends related to successful forms.

Select
Form,Extract(Year from ActionDate) as Approval_Year,DocType,
Count(*) as No_of_Forms
from product_dosageforms
where DocType != 'TA'
group by form
order by No_of_Forms DESC;

################################################################################################

# TASK 4: Exploring Therapeutic Classes and Approval Trends

create view TE_CODE_APPROVAL AS
Select P.Applno,PTE.TECode,P.ProductMktStatus,ActionDate
from Product as P
Join Product_TECode as PTE on PTE.ApplNo = P.ApplNo
Join Application as A on P.ApplNo = A.ApplNo
Join regactiondate as R on A.ApplNo = R.ApplNo;


# QUERY 1 : Analyze drug approvals based on therapeutic evaluation code (TE_Code).

Select
TEcode,count(*) as No_of_Approval
From TE_CODE_Approval
group by TEcode
Order by No_Of_Approval DESC;

# QUERY 2 : Determine the therapeutic evaluation code (TE_Code) with the highest number
# of Approvals in each year

Select
TEcode,Extract(Year from ActionDate) as Approval_Year,count(*) as No_of_Approval
From TE_CODE_Approval
group by TEcode,Approval_year
Order by No_Of_Approval DESC;
