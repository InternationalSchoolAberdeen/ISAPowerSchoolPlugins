select s.lastfirst as "Student Name", s.grade_level as "Grade", c.course_name as "Course Name", pgf.grade as "Final Grade", pgf.comment_value as "Final Comment", st.name as "Standard Name", sgs.standardgrade as "Standard Grade"
from cc
join students s on s.id = cc.studentid
join sections sec on sec.id = cc.sectionid
join courses c on c.course_number = sec.course_number
join schoolstaff ss on ss.id = cc.teacherid
join users u on u.dcid = ss.users_dcid
join pgfinalgrades pgf on pgf.sectionid=cc.sectionid and pgf.studentid=cc.studentid
join standardgradesection sgs on sgs.sectionsdcid =sec.dcid and sgs.studentsdcid = s.dcid
join standard st on st.standardid = sgs.standardid
where s.grade_level = '%param1%' and sgs.storecode='%param2%' and s.grade_level = sgs.gradelevel and s.enroll_status = 0 and sec.teacher = ~[x:userid]
order by s.lastfirst, sec.expression, decode(st.name, 'Collaboration', 1, 'Engagement', 2, 'Responsibility', 3, 4)