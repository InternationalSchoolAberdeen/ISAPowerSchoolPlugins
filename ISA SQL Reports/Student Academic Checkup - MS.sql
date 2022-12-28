select 
	distinct 
	s.lastfirst as "Student Name", 
	c.course_name as "Course Name", 
	st.name as "Standard Name", 
	sgs.standardgrade as "Standard Grade",
from 
	cc
join 
	students s on s.id = cc.studentid
join 
	sections sec on sec.id = cc.sectionid
join 
	courses c on c.course_number = sec.course_number
join 
	pgfinalgrades pgf on pgf.sectionid = cc.sectionid and pgf.studentid = cc.studentid
join 
	standardgradesection sgs on sgs.sectionsdcid = sec.dcid and sgs.studentsdcid = s.dcid
join 
	assignmentsection on assignmentsection.sectionsdcid = sgs.sectionsdcid
join 
	assignmentscore on assignmentscore.assignmentsectionid = assignmentsection.assignmentsectionid and assignmentscore.studentsdcid = s.dcid
join 
	standard st on st.standardid = sgs.standardid
where 
	s.grade_level in (8) and 
	floor(sec.termid/100) = ~(curyearid) and 
	sgs.storecode = 'S1' and 
	s.grade_level = sgs.gradelevel and 
	s.enroll_status = 0 and 
	sgs.standardgrade in ('1', '2', 'R', 'S') and 
	assignmentscore.ismissing = 1 and 
	assignmentscore.isexempt = 0
order by 
	s.lastfirst, sec.expression, decode(st.name, 'Collaboration', 1, 'Engagement', 2, 'Responsibility', 3, 4)