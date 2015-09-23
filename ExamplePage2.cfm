<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Standard Page</title>
</head>

<body>
Back to <a href="index.cfm">index.cfm</a><br><br>


<cfscript>
	//create new query
	qrySample = QueryNew("FirstName,LastName,Author");
	//add  row
	QueryAddRow(qrySample);
	QuerySetCell(qrySample,"FirstName","Brian");
	QuerySetCell(qrySample,"LastName","Edison");
	QuerySetCell(qrySample,"Author","E.A. Poe");	

</cfscript>

<!--- do samples query  --->
<cfquery name="selAllPeople" dbtype="query">
	SELECT *
	FROM qrySample
</cfquery>

<cfdump var="#selAllPeople#">

<br>
Debug Options passed in via URL:<br>
<cfdump var="#URL#">

<br>

Below we caused an error that we trap:
<cftry>
	<cfset Result=10/0>
	<cfcatch>
		<!--- do nothing --->
	
	</cfcatch>
</cftry>
</body>
</html>
