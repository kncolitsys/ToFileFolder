<!---
Component to assist with example and installation

Creative Commons License
http://creativecommons.org/licenses/by/3.0/
Bilal Soylu
10-22-2009
--->

<cfcomponent displayname="toFileExampleHelper" hint="helper component to assist with ToFile Example and Installation">

	<!--- constructor (bsoylu 10-25-2009) --->
	<cfset this.strDebugDir = Server.ColdFusion.RootDir & "\wwwroot\WEB-INF\debug">
	<cfset this.strToFilePath = this.strDebugDir & "\ToFile.cfm">

	<cffunction name="IsInstalled" access="public" returntype="boolean" hint="checks whether ToFile Debug has been installed on this system">
		<cfset var Local=StructNew()>		
		<cfset Local.blnReturn = FileExists("#this.strToFilePath#")>		
		<cfreturn Local.blnReturn>		
	</cffunction>
	
	<cffunction name="IsEnabled" access="public" returntype="boolean" hint="checks whether the installed ToFile debugging option is selected">
		<!--- neo-debug.xml contains config info about the current debug options (bsoylu 10-25-2009) --->
		<cfset var strFile="#Server.ColdFusion.RootDir#\lib\neo-debug.xml">
		<cfset var strFI = "">
		<cfset var arrCFDebugConfig = "">
		<cfset var blnIsEnabled = false>
		
		<!--- read the debug config file and convert to cf object (bsoylu 10-25-2009) --->
		<cffile action="READ" file="#strFile#" variable="strFI">		
		<cfwddx action="WDDX2CFML" input="#strFI#" output="arrCFDebugConfig">	
		
		<cfif arrCFDebugConfig[1].debug_template CONTAINS "ToFile.cfm">
			<cfset blnIsEnabled=true>
		</cfif>
		
		<cfreturn blnIsEnabled>
	</cffunction>
	
	<cffunction name="Install" access="public" returntype="boolean" hint="Copies the extension to the correct place on server">
		<cfset var Local=StructNew()>	
		<cfset Local.FromPath = GetDirectoryFromPath(GetCurrentTemplatePath()) & "ToFile.cfm">
		<cfset Local.ToPath =this.strToFilePath>	
		<cfset Local.blnSuccess = false>
		
		<cfif FileExists(Local.FromPath)>
			<cftry>
				<cffile action="COPY" source="#Local.FromPath#" destination="#Local.ToPath#"> 
				<cfset Local.blnSuccess = true>
				<cfcatch type="any">
					<!--- error to do here (bsoylu 10-25-2009) --->
					<b>Error during install</b>:Problem copying file to destination directory <br>
				</cfcatch>
			</cftry>
		</cfif>	

		<cfreturn Local.blnSuccess>
	</cffunction>	

</cfcomponent>
