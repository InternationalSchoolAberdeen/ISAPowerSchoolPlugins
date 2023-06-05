WITH ContactData AS (
    SELECT
        students.dcid,
        students.grade_level AS "Grade",
        u_def_ext_students3.bus AS "Bus Number",
        students.first_name || ' ' || students.last_name AS "Student Name",
        person.firstname || ' ' || person.lastname AS "Contact Name",
        phonenumber.phonenumber AS "Contact Number",
        emailaddress.emailaddress AS "Contact Email",
        CASE WHEN u_def_ext_students1.feetype like '%Staff%' THEN 'yes' ELSE 'no' END AS "Is Staff Child?",
        ROW_NUMBER() OVER (PARTITION BY students.dcid ORDER BY person.id) AS ContactRank
    FROM Students
    INNER JOIN studentcontactassoc ON students.dcid = studentcontactassoc.studentdcid
    INNER JOIN person ON studentcontactassoc.personid = person.id
    INNER JOIN studentcontactdetail ON studentcontactassoc.studentcontactassocid = studentcontactdetail.studentcontactassocid
    INNER JOIN personphonenumberassoc ON person.id = personphonenumberassoc.personid
    INNER JOIN phonenumber ON phonenumber.phonenumberid = personphonenumberassoc.phonenumberid
    INNER JOIN personemailaddressassoc ON person.id = personemailaddressassoc.personid
    INNER JOIN emailaddress ON personemailaddressassoc.emailaddressid = emailaddress.emailaddressid
    INNER JOIN codeset emailcodeset ON emailcodeset.codesetid = personemailaddressassoc.emailtypecodesetid
    INNER JOIN codeset phonecodeset ON phonecodeset.codesetid = personphonenumberassoc.phonetypecodesetid
    JOIN u_def_ext_students1 ON students.dcid = u_def_ext_students1.studentsdcid
    JOIN u_def_ext_students3 ON students.dcid = u_def_ext_students3.studentsdcid
    WHERE students.enroll_status IN (0, -1) AND phonecodeset.code = 'Mobile' AND phonenumber.phonenumber IS NOT NULL AND students.grade_level >= 0
)
SELECT
    "Student Name",
    "Grade",
    "Bus Number",
    MAX(CASE WHEN ContactRank = 1 THEN "Contact Name" || ', ' || "Contact Number" || ', ' || "Contact Email" END) AS "Contact 1",
    MAX(CASE WHEN ContactRank = 2 THEN "Contact Name" || ', ' || "Contact Number" || ', ' || "Contact Email" END) AS "Contact 2",
    "Is Staff Child?"
FROM ContactData
GROUP BY "Student Name", "Grade", "Is Staff Child?", "Bus Number"
ORDER BY "Grade", "Student Name"
