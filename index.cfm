<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>ToFile Offline Debugging</title>
</head>

<body>
<cfset DebugOnlyErrorToFile=true> <!--- suppress debugging to file of this page unless error (bsoylu 10-25-2009) --->

<cfset objHelper = CreateObject("component","ToFileHelper")>
<cfset lstOptions="DebugSilent,DebugOnlyErrorToFile,DebugErrorToEmail,DebugUserIDs">

<!--- check whether we should install the debug extension (bsoylu 10-25-2009) --->
<cfif IsDefined("Form.Install") AND NOT objHelper.IsInstalled()>
	<cfif objHelper.Install()>
		Install completed.. <br>
	<cfelse>
		Install failed..<br>
	</cfif>
</cfif>

<!--- process example call (bsoylu 10-27-2009) --->
<cfif IsDefined("Form.Process")>
	
	<cfset strURL="">
	<!--- cast options from Form to URL (bsoylu 10-27-2009) --->
	<cfloop list="#lstOptions#" index="idxOption">
		<cfif IsDefined("Form.#idxOption#") AND Form[idxOption] NEQ "">
			<cfset strURL = strURL & idxOption & "=" & URLEncodedFormat(Form[idxOption]) & "&">
		</cfif>
	</cfloop>
	<!--- decide which page to forward to (bsoylu 10-27-2009) --->
	<cfif IsDefined("Form.PageOption") AND Form.PageOption IS "Standard">
		<cflocation addtoken="No" url="ExamplePage1.cfm?#strURL#">
	<cfelse>
		<cflocation addtoken="No" url="ExamplePage2.cfm?#strURL#">
	</cfif>
</cfif>

<!---  we check whether the debug extension is installed (bsoylu 10-25-2009) --->

<cfif NOT objHelper.IsInstalled()>
	<!--- ask whether user would like to install it (bsoylu 10-25-2009) --->
	The ToFile Debug extension does not appear to have been installed correctly.<br/>
	Do you want to install it now?
	<form action="index.cfm" method="post">
		<input type="submit" name="install" id="install" value="Install ToFile Debug Extension">
	</form>
<cfelseif NOT objHelper.IsEnabled()>
	<!--- ask user to enable it in CF Admin (bsoylu 10-25-2009) --->	
	<h3>The ToFile Debug extension appears to be installed.</h3> 
	Please enable it in your ColdFusion Administrator to proceed with the samples (see below)<br><br>
	
	<img src="selection.gif" alt="display CF Admin with correct debug options selected">
	
<cfelse>
	<!--- direct to samples (bsoylu 10-25-2009) --->
	<h1>
	ToFile Offline Debugging
	</h1>
	
	<strong>Examples:</strong><br>
		
	
	<form action="index.cfm" method="post">
		<u>Select from the options:</u> <br>
		<input type="checkbox" name="DebugSilent" value="true"> DebugSilent <br>
		<input type="checkbox" name="DebugOnlyErrorToFile" value="true"> DebugOnlyErrorToFile <br>
		<input type="text" name="DebugErrorToEmail" value=""> DebugErrorToEmail <br>
		<input type="text" name="DebugUserIDs" value=""> DebugUserIDs (You need to set Session.UserID= in your code)
		
		
		
		<br><br>	
		<u>Select type of Page:</u><br>
		<input type="radio" name="PageOption" value="Standard" checked>Standard Page
		<input type="radio" name="PageOption" value="Error">Page with Error
		<br><br>
		<input type="submit" name="Process" value="Run Example">
	</form>
	<hr noshade>
	
	<strong>Description:</strong><br>
This is an alternate template for Debug output based on the Classic ColdFusion Debug output.
It will allow unattended capture of debug information to file system as requests are being made.
It has the same overhead characteristics as leaving Debug on, so it should be used temporarily.

Thus, please do not keep this debug option enabled as it may cause your drive to fill up.

To use this, please copy this file to your ColdFusion debug directory normally located here:
[cfroot]\wwwroot\WEB-INF\debug
Then access your ColdFusion Administrator Debug Settings page and select ToFile.cfm from the drop down menu 
for Debug Output Format.

Files will be written to the ColdFusion temp directory normally located here:
[cfroot]\runtime\servers\coldfusion\SERVER-INF\temp\wwwroot-tmp\U00

The following flags can be provided in either variable, form, or url scope to direct the behavior of this debug
processing.
You can set the flags in URL or in Request scope.
A good place for setting these would be in Application.cfc

DebugSilent  			=> if this is defined the final line at the bottom of the output will be supressed, default: False
DebugOnlyErrorToFile	=> only write files when there is an error (even if caught with cftry/cfcatch), default: False 
DebugErrorToEmail		=> attempt to send Error debug output to this email address
DebugTemplates			=> CSV list of templates names (only the filename not the path), if you only want to capture debug information only for certain templates, e.g. GetCart.cfm 
DebugUserRoles		    => CSV list of roles, if you are using cflogin framework, you can restrict capture to user in given role, e.g. admins
DebugUserIDs			=> if you are using Session.UserIDs a list of IDs for which to capture debug, see  below:

Using Session.UserID:
If you use Session.UserID as a variable in your applications the last directory will carry the user ID, e.g. 
for user with Session.UserID=34 the subdirectory in which the debug output will be stored would be U34
[cfroot]\runtime\servers\coldfusion\SERVER-INF\temp\wwwroot-tmp\U34

<br>

</cfif>

</body>
</html>
