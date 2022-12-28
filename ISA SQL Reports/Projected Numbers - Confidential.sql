select
	Grade,
	Non_Corp_Self as "Non Corporate / Self Pay",
	Corp_Company as "Corporate / Company Pay",
	Staff,
	Financial_Aid as "Financial Aid",
	University_Researcher_Discount as "University Researcher Discount",
	Ukraine as "Ukraine Sponsor",
	IB as "IB Scholarship"
from (
(select
  Grade_Level as Grade,
  count(
    case when FeeType like '%self%' then 1 else null end
  ) as Non_Corp_Self,
  count(
    case when FeeType like '%company%' then 1 else null end
  ) as Corp_Company,
  count(
    case when FeeType like '%Staff%' then 1 else null end
  ) as Staff,
  count(
    case when FeeType like '%Aid%' then 1 else null end
  ) as Financial_Aid,
  count(
    case when FeeType like '%University%' then 1 else null end
  ) as University_Researcher_Discount,
  count(
    case when FeeType like '%Ukraine%' then 1 else null end
  ) as Ukraine,
  count(
    case when FeeType like '%IB%' then 1 else null end
  ) as IB
FROM
  students s
  JOIN U_DEF_EXT_STUDENTS1 ON U_DEF_EXT_STUDENTS1.studentsdcid = s.dcid
WHERE
  s.enroll_status = 0
group by
  Grade_Level)
  
union

(select
  cast('' as int),
  sum(
    case when FeeType like '%self%' then 1 else null end
  ),
  sum(
    case when FeeType like '%company%' then 1 else null end
  ),
  sum(
    case when FeeType like '%Staff%' then 1 else null end
  ),
  sum(
    case when FeeType like '%Aid%' then 1 else null end
  ),
  sum(
    case when FeeType like '%University%' then 1 else null end
  ),
  sum(
    case when FeeType like '%Ukraine%' then 1 else null end
  ),
  sum(
    case when FeeType like '%IB%' then 1 else null end
  )
from
  students s
  JOIN U_DEF_EXT_STUDENTS1 ON U_DEF_EXT_STUDENTS1.studentsdcid = s.dcid
WHERE
  s.enroll_status = 0)
) order by Grade