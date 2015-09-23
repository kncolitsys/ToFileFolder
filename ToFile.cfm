<!---
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

--->

<cfif IsDebugMode()>
<cfsilent>
<cfset startTime = getTickCount()>
<cfscript>
	formEncoding = getEncoding("FORM");
	urlEncoding = getEncoding("URL");

	setEncoding("FORM", formEncoding);
	setEncoding("URL", urlEncoding);
</cfscript>
</cfsilent>



	<!--- Localized strings --->
	<cfset undefined = "">
	<!--- Use the debugging service to check options --->
	<cftry>
		<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
		<cfset cfdebugger = factory.getDebuggingService()>
		<cfcatch type="Any"></cfcatch>
	</cftry>

	<!--- Load the debugging service's event table --->
	<cfset qEvents = cfdebugger.getDebugger().getData()>

	<!--- Produce the filtered event queries --->
	<!--- EVENT: Templates --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_templates" debug="false">
			SELECT template, parent, Sum(endTime - StartTime) AS et
			FROM qEvents
			WHERE type = 'Template'
			GROUP BY template, parent
			ORDER BY et DESC
		</cfquery>
		<cfscript>
			if( cfdebug_templates.recordCount eq 1 and not len(trim(cfdebug_templates.et)) )
			{
				querySetCell(cfdebug_templates, "et", "0", 1);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_templates = queryNew('template, parent, et');
			</cfscript>
		</cfcatch>
	</cftry>


	<!--- EVENT: SQL Queries --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_queries" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'SqlQuery'
		</cfquery>
		<cfscript>
			if( cfdebug_queries.recordCount eq 1 and not len(trim(cfdebug_queries.executionTime)) )
			{
				querySetCell(cfdebug_queries, "executionTime", "0", 1);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_queries = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL, et');
			</cfscript>		
		</cfcatch>
	</cftry>

	
	<!--- EVENT: Object Queries --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_cfoql" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'ObjectQuery'
		</cfquery>
		<cfscript>
			if( cfdebug_cfoql.recordCount eq 1 and not len(trim(cfdebug_cfoql.executionTime)) )
			{
				querySetCell(cfdebug_cfoql, "executionTime", "0", 1);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_cfoql = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>				
		</cfcatch>
	</cftry>
	
	<!--- EVENT: Stored Procedures --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_storedproc" debug="false">
			SELECT *, (endTime - startTime) AS executionTime
			FROM qEvents
			WHERE type = 'StoredProcedure'
		</cfquery>
		<cfscript>
			if( cfdebug_storedproc.recordCount eq 1 and not len(trim(cfdebug_storedproc.executionTime)) )
			{
				querySetCell(cfdebug_storedproc, "executionTime", "0", 1);
			}
		</cfscript>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_storedproc = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>						
		</cfcatch>
	</cftry>
	
	<!--- EVENT: Trace Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_trace" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'Trace'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_trace = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>						
		</cfcatch>
	</cftry>
	
	<!--- EVENT: CFTimer Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_timer" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'CFTimer'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_timer = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>						
		</cfcatch>
	</cftry>
	
	<!--- EVENT: Locking Warning Points --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_lock" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'LockWarning'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_lock = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>						
		</cfcatch>
	</cftry>
	
	<!--- EVENT: Exceptions --->
	<cftry>
		<cfquery dbType="query" name="cfdebug_ex" debug="false">
			SELECT *
			FROM qEvents
			WHERE type = 'Exception'
		</cfquery>
		<cfcatch type="Any">
			<cfscript>
				cfdebug_ex = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
			</cfscript>						
		</cfcatch>
	</cftry>

	
	<!--- Establish Section Display Flags --->
	<cfparam name="displayDebug" default="false" type="boolean"><!--- ::	display the debug time 	:: --->
	<cfparam name="bGeneral" default="false" type="boolean">
	<cfparam name="bFoundExecution" default="false" type="boolean">
	<cfparam name="bFoundTemplates" default="false" type="boolean">
	<cfparam name="bFoundExceptions" default="false" type="boolean">
	<cfparam name="bFoundSQLQueries" default="false" type="boolean">
	<cfparam name="bFoundObjectQueries" default="false" type="boolean">
	<cfparam name="bFoundStoredProc" default="false" type="boolean">
	<cfparam name="bFoundTrace" default="false" type="boolean">
	<cfparam name="bFoundTimer" default="false" type="boolean">
	<cfparam name="bFoundLocking" default="false" type="boolean">
	<cfparam name="bFoundScopeVars" default="false" type="boolean">
	
	<cftry>
		<cfscript>
	        // no longer doing template query at the top since we have tree and summary mode
			bFoundTemplates = cfdebugger.check("Template");
			
			if( bFoundTemplates )
			{ displayDebug=true; }

			if ( isDefined("cfdebugger.settings.general") and cfdebugger.settings.general )
			{ bGeneral = true; displayDebug=true; }
			
			if (IsDefined("cfdebug_ex") AND cfdebug_ex.recordCount GT 0) { bFoundExceptions = true; displayDebug=true; }
			else { bFoundExceptions = false; }
			
			if (IsDefined("cfdebug_queries") AND cfdebug_queries.RecordCount GT 0) { bFoundSQLQueries = true; displayDebug=true; }
			else { bFoundSQLQueries = false; }
			
			if (IsDefined("cfdebug_cfoql") AND cfdebug_cfoql.RecordCount GT 0) { bFoundObjectQueries = true; displayDebug=true; }
			else { bFoundObjectQueries = false; }
			
			if (IsDefined("cfdebug_storedproc") AND cfdebug_storedproc.RecordCount GT 0) { bFoundStoredProc = true; displayDebug=true; }
			else { bFoundStoredProc = false; }
			
			if (IsDefined("cfdebug_trace") AND cfdebug_trace.recordCount GT 0) { bFoundTrace = true; displayDebug=true; }
			else { bFoundTrace = false; }
			
			if (IsDefined("cfdebug_timer") AND cfdebug_timer.recordCount GT 0) { bFoundTimer = true; displayDebug=true; }
			else { bFoundTimer = false; }			
			
			if (IsDefined("cfdebug_lock") AND cfdebug_lock.recordCount GT 0) { bFoundLocking = true; displayDebug=true; }
			else { bFoundLocking = false; }
			
			if (IsDefined("cfdebugger") AND cfdebugger.check("Variables")) { bFoundScopeVars = true; displayDebug=true; }
			else { bFoundScopeVars = false; }
		</cfscript>
		<cfcatch type="Any"></cfcatch>
	</cftry>



<cfsetting enablecfoutputonly="Yes">

<cfsavecontent variable="strDebugHTML">

<cfif displayDebug>
<cfoutput>
</td></td></td></th></th></th></tr></tr></tr></table></table></table></a></abbrev></acronym></address></applet></au></b></banner></big></blink></blockquote></bq></caption></center></cite></code></comment></del></dfn></dir></div></div></dl></em></fig></fn></font></form></frame></frameset></h1></h2></h3></h4></h5></h6></head></i></ins></kbd></listing></map></marquee></menu></multicol></nobr></noframes></noscript></note></ol></p></param></person></plaintext></pre></q></s></samp></script></select></small></strike></strong></sub></sup></table></td></textarea></th></title></tr></tt></u></ul></var></wbr></xmp>
<style type="text/css">
.cfdebug
{
	color:black; 
	background-color:white; 
	font-family:"Times New Roman", Times, serif; 
	font-size:small
}

.cfdebuglge
{
	color:black; 
	background-color:white; 
	font-family:"Times New Roman", Times, serif; 
	font-size:medium;
}

a.cfdebuglink {color:blue; background-color:white }
</style>
<table class="cfdebug" bgcolor="white">
<tr>
	<td>
</cfoutput>
</cfif>



<cfif bGeneral>
<cfoutput>
	<cftry>
		<p class="cfdebug"><hr/>
		<b class="cfdebuglge"><a name="cfdebug_top">Debugging Information</a></b>
		<table class="cfdebug">
		<tr>
			<td class="cfdebug" nowrap>#server.coldfusion.productname# #server.coldfusion.productlevel#</td>
			<td class="cfdebug">#server.coldfusion.productversion#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Template </td>
			<td class="cfdebug">#xmlFormat(CGI.Script_Name)#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Time Stamp </td>
			<td class="cfdebug">#DateFormat(Now())# #TimeFormat(Now())#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Locale </td>
			<td class="cfdebug">#GetLocale()#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> User Agent </td>
			<td class="cfdebug">#CGI.HTTP_USER_AGENT#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Remote IP </td>
			<td class="cfdebug">#CGI.REMOTE_ADDR#</td>
		</tr>
		<tr>
			<td class="cfdebug" nowrap> Host Name </td>
			<td class="cfdebug">#CGI.REMOTE_HOST#</td>
		</tr>
		</table>
		</p>
		<cfcatch type="Any"></cfcatch>
	</cftry>
</cfoutput>
</cfif>

<!--- Template Stack and Executions Times --->
<cfif bFoundTemplates>        
  	<!--- Total Execution Time of all top level pages --->
  	<cfquery dbType="query" name="cfdebug_execution" debug="false">
      	SELECT (endTime - startTime) AS executionTime
      	FROM qEvents
      	WHERE type = 'ExecutionTime'
  	</cfquery>
	<!--- ::	
		in the case that no execution time is recorded. 
		we will add a value of -1 so we know that a problem exists but the template continues to run properly.	
		:: --->
	<cfif not cfdebug_execution.recordCount>
		<cfscript>
			queryAddRow(cfdebug_execution);
			querySetCell(cfdebug_execution, "executionTime", "-1");
		</cfscript>
	</cfif>
	
	
  	<cfquery dbType="query" name="cfdebug_top_level_execution_sum" debug="false">
  		SELECT sum(endTime - startTime) AS executionTime
	  	FROM qEvents
  		WHERE type = 'Template' AND parent = ''
  	</cfquery>

    <!--- File not found will not produce any records when looking for top level pages --->
    <cfif cfdebug_top_level_execution_sum.recordCount and len(trim(cfdebug_top_level_execution_sum.executionTime[1])) gt 0>
        <cfset time_other = Max(cfdebug_execution.executionTime - val(cfdebug_top_level_execution_sum.executionTime), 0)>    
        <cfoutput>
			<style type="text/css">
            .template
            {	color: black; 
            	font-family: "Times New Roman", Times, serif; 
            	font-weight: normal; }
            .template_overage
            {	color: red; 
            	background-color: white; 
            	font-family: "Times New Roman", Times, serif; 
            	font-weight: bold; }
            </style>
       		<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_execution">Execution Time</a></b></p>
            <a name="cfdebug_templates">
        </cfoutput>
            
        <cfif cfdebugger.settings.template_mode EQ "tree">
            <cfset a = arrayNew(1)>
            <cfloop query="qEvents">
               <cfscript>
                    // only want templates, IMQ of SELECT * ...where type = 'template' will result
                    // in cannot convert the value "" to a boolean for cachedquery column
                    // SELECT stacktrace will result in Query Of Queries runtime error.
                    // Failed to get meta_data for columnqEvents.stacktrace .
                    // Was told I need to define meta data for debugging event table similar to <cfldap>
                    if( qEvents.type eq "template" ) {
                        st = structNew();
                        st.StackTrace = qEvents.stackTrace;
                        st.template = qEvents.template;
                        st.startTime = qEvents.starttime;
                        st.endTime = qEvents.endtime;
                        st.parent =  qEvents.parent;
                        st.line =  qEvents.line;
                        
                        arrayAppend(a, st);
                    }
               </cfscript>
            </cfloop>
            <cfset qTree = queryNew("template,templateId,parentId,duration,line")>
            <cfloop index="i" from="1" to="#arrayLen(a)#">
                <cfset childidList = "">
                <cfset parentidList = "">
                <cfloop index="x" from="#arrayLen(a[i].stacktrace.tagcontext)#" to="1" step="-1">
                    <cfscript>
                        if( a[i].stacktrace.tagcontext[x].id NEQ "CF_INDEX" ) {
                            // keep appending the line number from the template stack to form a unique id
                            childIdList = listAppend(childIdList, a[i].stacktrace.tagcontext[x].line);
                            if( x eq 1 ) {
                                parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template);
                            } else {
                                parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].line);
                            }
                        }
                    </cfscript>
                </cfloop>
            
                <cfscript>
                    // template is the last part of the unique id...12,5,17,c:\wwwroot\foo.cfm
                    // if we don't remove the "CFC[" prefix, then the parentId and childId relationship
                    // will be all wrong
                    startToken = "CFC[ ";
                    endToken = " | ";
                    thisTemplate = a[i].template;
                    startTokenIndex = FindNoCase(startToken, thisTemplate, 1);
                    if( startTokenIndex NEQ 0 ) {
                        endTokenIndex = FindNoCase(endToken, thisTemplate, startTokenIndex);
                        thisTemplate = Trim(Mid(thisTemplate,Len(startToken),endTokenIndex-Len(startToken)));
                    }
                    childIdList = listAppend(childIdList, thisTemplate);
                    
                    queryAddRow(qTree);
                    querySetCell(qTree, "template", a[i].template);    
                    querySetCell(qTree, "templateId", childIdList);    
                    querySetCell(qTree, "parentId", parentIdList);    
                    querySetCell(qTree, "duration", a[i].endtime - a[i].starttime);    
                    querySetCell(qTree, "line", a[i].line);    
                </cfscript>
            </cfloop>
            
            <cfset stTree = structNew()>
            <cfloop query="qTree">
                <cfscript>
                // empty parent assumed to be top level with the exception of application.cfm
                if( len(trim(parentId)) eq 0 ){
                    parentId = 0;
                }
                    stTree[parentId] = structNew();
                    stTree[parentId].templateId = qTree.templateId;
                    stTree[parentId].template = qTree.template;
                    stTree[parentId].duration = qTree.duration;
                    stTree[parentId].line = qTree.line;
                    stTree[parentId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    stTree[templateId] = structNew();
                    stTree[templateId].templateId = qTree.templateId;
                    stTree[templateId].template = qTree.template;
                    stTree[templateId].duration = qTree.duration;
                    stTree[templateId].line = qTree.line;
                    stTree[templateId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    arrayAppend(stTree[parentId].children, stTree[templateId]);
                </cfscript>
            </cfloop>
            
            <cfquery dbType="query" name="topNodes" debug="false">
                SELECT parentId, templateid
                FROM qTree
                WHERE parentId = ''
            </cfquery>

           
            <cfoutput query="topNodes">
                #drawTree(stTree,-1,topNodes.templateid,cfdebugger.settings.template_highlight_minimum)#
            </cfoutput> 
            <cfoutput><p class="template">
                (#time_other# ms) STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN<br />
                (#cfdebug_execution.executionTime# ms) TOTAL EXECUTION TIME<br />
                <font color="red"><span class="template_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms execution time</span></font>
                </p></cfoutput>
        <cfelse>
        	<cftry>
                <cfquery dbType="query" name="cfdebug_templates_summary" debug="false">
	                SELECT  template, Sum(endTime - startTime) AS totalExecutionTime, count(template) AS instances
	                FROM qEvents
	                WHERE type = 'Template'
	                group by template
	                order by totalExecutionTime DESC
                </cfquery>
                <cfoutput>
                <table border="1" cellpadding="2" cellspacing="0" class="cfdebug">
                <tr>
					<td class="cfdebug" align="center"><b>Total Time</b></td>
					<td class="cfdebug" align="center"><b>Avg Time</b></td>
					<td class="cfdebug" align="center"><b>Count</b></td>
					<td class="cfdebug"><b>Template</b></td>
				</tr>
                </cfoutput>
        
                <cftry>
                    <cfoutput query="cfdebug_templates_summary">
                        <cfset templateOutput = template>
                        <cfset templateAverageTime = Round(totalExecutionTime / instances)>
                        
                        <cfif template EQ ExpandPath(cgi.script_name)>
                            <cfset templateOutput = "" &
                                "<b>" & template & "</b>">
							 <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
                                <cfset templateOutput = "<font color='red'><span class='template_overage'>" & template & "</span></font>">
                                <cfset templateAverageTime = "<font color='red'><span class='template_overage'>" & templateAverageTime & "</span></font>">
								<cfset totalTime = "<font color='red'><span class='template_overage'>" & totalExecutionTime & "</span></font>">
                            </cfif>
                        <cfelse>
                            <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
                                <cfset templateOutput = "<font color='red'><span class='template_overage'>" & template & "</span></font>">
                                <cfset templateAverageTime = "<font color='red'><span class='template_overage'>" & templateAverageTime & "</span></font>">
								<cfset totalTime = "<font color='red'><span class='template_overage'>" & totalExecutionTime & "</span></font>">
                            </cfif>
                        </cfif>
    
                        <tr>
							<cfif isDefined("totalTime") and len(trim(totalTime))>
								<td align="right" class="cfdebug" nowrap>#totalTime# ms</td>
								<cfset totalTime = "">
							<cfelse>
    	                        <td align="right" class="cfdebug" nowrap>#totalExecutionTime# ms</td>
							</cfif>
                            <td align="right" class="cfdebug" nowrap>#templateAverageTime# ms</td>
                            <td align="center" class="cfdebug" nowrap>#instances#</td>
                            <td align="left" class="cfdebug" nowrap>#templateOutput#</td>
                        </tr>
                        </cfoutput>
                	<cfcatch type="Any"></cfcatch>
                </cftry>
                <cfoutput>
                <tr>
					<td align="right" class="cfdebug" nowrap><i>#time_other# ms</i></td><td colspan=2>&nbsp;</td>
                    <td align="left" class="cfdebug"><i>STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN</i></td>
				</tr>
                <tr>
					<td align="right" class="cfdebug" nowrap><i>#cfdebug_execution.executionTime# ms</i></td><td colspan=2>&nbsp;</td>
                    <td align="left" class="cfdebug"><i>TOTAL EXECUTION TIME</i></td>
				</tr>
                </table>
                <font color="red"><span class="template_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms average execution time</span></font>
                </a>
            	</cfoutput>
        	<cfcatch type="Any"></cfcatch>
    
        	</cftry>
        </cfif> <!--- template_mode = summary--->
    <cfelse>
        <p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_execution">Execution Time</a></b></p>
        <a name="cfdebug_templates">
        No top level page was found.
    </cfif> <!--- if top level templates are available --->
</cfif>



<!--- Exceptions --->
<cfif bFoundExceptions>
<cftry>
<cfoutput>
	<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_exceptions">Exceptions</a></b></p>
	<cfloop query="cfdebug_ex">
	    <div class="cfdebug">#TimeFormat(cfdebug_ex.timestamp, "HH:mm:ss.SSS")# - #cfdebug_ex.name# <cfif FindNoCase("Exception", cfdebug_ex.name) EQ 0>Exception</cfif> - in #cfdebug_ex.template# : line #cfdebug_ex.line#</div>
	    <cfif IsDefined("cfdebug_ex.message") AND Len(Trim(cfdebug_ex.message)) GT 0>
	    <pre>
	    #cfdebug_ex.message#
	    </pre>
	    </cfif>
	</cfloop>
</cfoutput>
	<cfcatch type="Any">
		<!--- Error reporting an exception event entry. --->	
	</cfcatch>
</cftry>
</cfif>

<!--- SQL Queries --->
<cfoutput>
<cfif bFoundSQLQueries>
	<cftry>
		<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_sql">SQL Queries</a></b></p>
		<cfloop query="cfdebug_queries">
			<code><b>#cfdebug_queries.name#</b> (Datasource=#cfdebug_queries.datasource#, Time=#Max(cfdebug_queries.executionTime, 0)#ms<cfif IsDefined("cfdebug_queries.rowcount") AND IsNumeric(cfdebug_queries.rowcount)>, Records=#Max(cfdebug_queries.rowcount, 0)#<cfelseif IsDefined("cfdebug_queries.result.recordCount")>, Records=#cfdebug_queries.result.recordCount#</cfif><cfif cfdebug_queries.cachedquery>, Cached Query</cfif>) in #cfdebug_queries.template# @ #TimeFormat(cfdebug_queries.timestamp, "HH:mm:ss.SSS")#</code><br />
			<pre>#htmleditformat(cfdebug_queries.body)#</pre>
			
			<cfif arrayLen(cfdebug_queries.attributes) GT 0>
			    <code>Query Parameter Value(s) -<br />
			
			    <cfloop index="x" from=1 to="#arrayLen(cfdebug_queries.attributes)#">
	        		<cfset thisParam = #cfdebug_queries.attributes[cfdebug_queries.currentRow][x]#>
			        Parameter ###x#<cfif StructKeyExists(thisParam, "sqlType")>(#thisParam.sqlType#)</cfif> = <cfif StructKeyExists(thisParam, "value")>#htmleditformat(thisParam.value)#</cfif><br />
			    </cfloop>
			    </code><br />
			</cfif>
		</cfloop>
	<cfcatch type="Any">
		<!--- Error reporting query event --->
	</cfcatch>
</cftry>
</cfif>

<!--- Stored Procs --->
<cfif bFoundStoredProc>
<cftry>
<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_storedproc">Stored Procedures</a></b></p>
<p class="cfdebug">
<cfloop query="cfdebug_storedproc">
<!--- Output stored procedure details, remember, include result (output params) and attributes (input params) columns --->
<code><b>#cfdebug_storedproc.name#</b> (Datasource=#cfdebug_storedproc.datasource#, Time=#Max(cfdebug_storedproc.executionTime, 0)#ms) in #cfdebug_storedproc.template# @ #TimeFormat(cfdebug_storedproc.timestamp, "HH:mm:ss.SSS")#</code><br />
    <table border=0 cellpadding=0 cellspacing=0>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td>
            <table border=1 cellpadding=2 cellspacing=2>
            <tr bgcolor="gray"><td colspan="5" align="center"><font color="white">parameters</font></td></tr>
            <tr><td><code><i>type</i></code></td><td><code><i>CFSQLType</i></code></td><td><code><i>value</i></code></td><td><code><i>variable</i></code></td><td><code><i>dbVarName</i></code></td></tr>
            
            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.attributes)#">
            <cfset thisParam = #cfdebug_storedproc.attributes[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "type")>#thisParam.type#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "sqlType")>#thisParam.sqlType#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "value")>#htmleditformat(thisParam.value)#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "variable")>#thisParam.variable# = #CFDebugSerializable(thisParam.variable)#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "dbVarName")>#thisParam.dbVarName#</cfif></code></td>
            </tr>
            </cfloop>
            </table>
        </td>
    </tr>
    <tr>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td>
            <table border=1 cellpadding=2 cellspacing=2>
            <tr bgcolor="gray"><td colspan="5" align="center"><font color="white">resultsets</font></td></tr>
            <tr><td><code><i>name</i></code></td><td><code><i>resultset</i></code></td></tr>
            
            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.result)#">
            <cfset thisParam = #cfdebug_storedproc.result[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "name")>#thisParam.name#</cfif></code></td>
                <td>&nbsp;<code><cfif StructKeyExists(thisParam, "resultSet")>#thisParam.resultSet#</cfif></code></td>
            </tr>
            </cfloop>
            </table>
        </td>
    </tr>
    </table>
</cfloop>
</p>
	<cfcatch type="Any">
		<!--- Error reporting stored proc event --->
	</cfcatch>
</cftry>
</cfif>

<!--- :: CFTimer :: --->
<cfif bFoundTimer>
<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_timer">CFTimer Times</a></b></p>
<p class="cfdebug">

<cfloop query="cfdebug_timer">
    <cftry>
    	--
		 [#val(cfdebug_timer.endTime) - val(cfdebug_timer.startTime)#ms] <i>#cfdebug_timer.message#</i><br />
    	<cfcatch type="Any"></cfcatch>
    </cftry>
</cfloop>
</p>
</cfif>


<!--- Tracing --->
<cfif bFoundTrace>
<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_trace">Trace Points</a></b></p>
<p class="cfdebug">

<cfset firstTrace=true>
<cfset prevDelta=0>
<cfloop query="cfdebug_trace">
    <cfset deltaFromRequest = Val(cfdebug_trace.endTime)>
    <cfset deltaFromLast = Val(deltaFromRequest-prevDelta)>
    <cftry>
    	-- [#TimeFormat(cfdebug_trace.timestamp, "HH:mm:ss.lll")# #cfdebug_trace.template# @ line: #cfdebug_trace.line#] [#deltaFromRequest# ms (<cfif firstTrace>1st trace<cfelse>#deltaFromLast# ms</cfif>)] - <cfif #cfdebug_trace.category# NEQ "">[#cfdebug_trace.category#]</cfif> <cfif #cfdebug_trace.result# NEQ "">[#cfdebug_trace.result#]</cfif> <i>#cfdebug_trace.message#</i><br />
    	<cfcatch type="Any"></cfcatch>
    </cftry>
    <cfset prevDelta = deltaFromRequest>
    <cfset firstTrace=false>
</cfloop>
</p>
</cfif>


<!--- SCOPE VARIABLES --->
<cfif bFoundScopeVars>
<p class="cfdebug"><hr/><b class="cfdebuglge"><a name="cfdebug_scopevars">Scope Variables</a></b></p>

<cftry>
<cfif IsDefined("APPLICATION") AND IsStruct(APPLICATION) AND StructCount(APPLICATION) GT 0 AND cfdebugger.check("ApplicationVar")>
<pre><b>Application Variables:</b>
#sortedScope(application)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("CGI") AND IsStruct(CGI) AND StructCount(CGI) GT 0 AND cfdebugger.check("CGIVar")>
<pre><b>CGI Variables:</b>
#sortedScope(cgi)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("CLIENT") AND IsStruct(CLIENT) AND StructCount(CLIENT) GT 0 AND cfdebugger.check("ClientVar")>
<pre><b>Client Variables:</b>
#sortedScope(client)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("COOKIE") AND IsStruct(COOKIE) AND StructCount(COOKIE) GT 0 AND cfdebugger.check("CookieVar")>
<pre><b>Cookie Variables:</b>
#sortedScope(cookie)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("FORM") AND IsStruct(FORM) AND StructCount(FORM) GT 0 AND cfdebugger.check("FormVar")>
<pre><b>Form Fields:</b>
#sortedScope(form)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("REQUEST") AND IsStruct(REQUEST) AND StructCount(REQUEST) GT 0 AND cfdebugger.check("RequestVar")>
<pre><b>Request Parameters:</b>
#sortedScope(request)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("SERVER") AND IsStruct(SERVER) AND StructCount(SERVER) GT 0 AND cfdebugger.check("ServerVar")>
<pre><b>Server Variables:</b>
#sortedScope(server)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("SESSION") AND IsStruct(SESSION) AND StructCount(SESSION) GT 0 AND cfdebugger.check("SessionVar")>
<pre><b>Session Variables:</b>
#sortedScope(session)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("URL") AND IsStruct(URL) AND StructCount(URL) GT 0 AND cfdebugger.check("URLVar")>
<pre><b>URL Parameters:</b>
#sortedScope(url)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>
</cfif>

<cfset duration = getTickCount() - startTime>
<cfif displayDebug>
<font size="-1" class="cfdebug"><i>Debug Rendering Time: #duration# ms</i></font><br />

	</td>
</tr>
</table>
</cfif>
</cfoutput>	
</cfsavecontent>	

<cfsetting enablecfoutputonly="No">
</cfif>



<cfscript>
//UDF - Handle output of complex data types.
function CFDebugSerializable(variable)
{
var ret = "";
try
    {
		if(IsSimpleValue(variable))
		{ 
			ret = xmlFormat(variable);
		}
		else
		{
			if (IsStruct(variable))
			{
				ret = ("Struct (" & StructCount(variable) & ")");
			}
			else if(IsArray(variable))
			{
				ret = ("Array (" & ArrayLen(variable) & ")");
			}
			else if(IsQuery(variable))
			{
				ret = ("Query (" & variable.RecordCount & ")");
			}
			else
			{
				ret = ("Complex type");
			}
		}
}
    catch("any" ex)
    {
        ret = "undefined";
    }
    return ret;
}
// UDF - tree writing
function drawNode(nTree, indent, id, highlightThreshold) {
    var templateOuput = "";
    if( nTree[id].duration GT highlightThreshold ) {
        templateOutput = "<font color='red'><span class='template_overage'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span></font><br>";
    } else {
        templateOutput = "<span class='template'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span><br>";
    }
    writeOutput(repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " --&gt; " & templateOutput);
    return "";
}

function drawTree(tree, indent, id, highlightThreshold) {
    var alength = 1; 
    var i = 1;
    var templateOuput = "";

	if( structKeyExists(tree, id) )
	{
	    // top level nodes (application.cfm,cgi.script_name,etc) have a -1 parent line number
	    if(tree[id].line EQ -1) {
			if( Tree[id].duration GT highlightThreshold ) 
			{
	        	writeoutput( "&middot; " & "<font color='red'><span class='template_overage'><b>(#Tree[id].duration#ms) " & Tree[id].template & "</b></span></font><br>" );
			}
			else
			{
				writeoutput( "&middot; " & "<span class='template'><b>(#Tree[id].duration#ms) " & Tree[id].template & "</b></span><br>" );
			}
	    } else {
	        if( Tree[id].duration GT highlightThreshold ) {
	            templateOutput = "<font color='red'><span class='template_overage'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span></font><br>";
	        } else {
	            templateOutput = "<span class='template'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span><br>";
	        }
	        writeoutput( repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " --&gt;  " & templateOutput );
	    }
	
	    if( isArray( tree[id].children ) and arrayLen( tree[id].children ) ) {
	        alength = arrayLen( tree[id].children );
	        for( i = 1; i lte alength; i = i + 1 ) {
	            if( isArray(tree[id].children[i].children) and arrayLen( tree[id].children[i].children ) gt 0 ) {
	                drawTree(tree, indent + 1, tree[id].children[i].templateid, highlightThreshold);
	            } else {
	                drawNode(tree, indent + 1, tree[id].children[i].templateid, highlightThreshold);
	            }
	        }
	    } else {
	        // single template, no includes?
	        //drawNode(tree, indent + 1, tree[id].template, highlightThreshold);
	    }
	}
    return "";
}
</cfscript>

<!---
	You can define the following variables either in Form/URL/or Variable Scopes:
		DebugUserIDs => these are user IDs in Session scope for which we will write files, both Session.UserID and DebugUserIDs have to be defined
		DebugSilent  => will suppress the two lines written to end output indicated the time and file path
	The following variables can be used in session scope
		Session.UserID => If you have defined a session user ID, a subdirectory will be created for each user
					      correspoding to the letter U + Session.UserID
	
--->
<cfif strDebugHTML NEQ "">
	<cfset blnDoDebugFileWrite = true>
	
	<!--- check for request scope vars they act as override (bsoylu 12-19-2012) --->
	<cfset lstDebugRequestVars = "DebugSilent,DebugTemplates,DebugUserRoles,DebugUserIDs,DebugErrorToEmail,DebugOnlyErrorToFile">
	<cfloop list="#lstDebugRequestVars#" index="idxReqScope">
		<cfif StructKeyExists(Request,idxReqScope)>
			<cfset "#idxReqScope#" = Request[idxReqScope]>
		</cfif>
	</cfloop>	
	
	<cfparam name="DebugSilent" default="false" type="boolean">
	<cfparam name="DebugTemplates" default="" type="string">
	<cfparam name="DebugUserRoles" default="" type="string">

	<!--- only capture debug for selectice templates (bsoylu 02-23-2010) --->
	<cfif DebugTemplates NEQ "">
		<cfif ListFind(DebugTemplates,ListLast(CGI.SCRIPT_NAME,"/")) IS 0>
			<cfset blnDoDebugFileWrite = false>
			<cfset strFileName="-- debug file write skipped (1).">	
		</cfif>	
	</cfif>
	
	<!--- only capture debug for selectice user roles, disable if none of the roles is in list (bsoylu 02-23-2010) --->
	<cfif DebugUserRoles NEQ "">
		<cfset blnSkipUserRoleForDebug = true>
		<cfloop list="#DebugUserRoles#" index="idxRole">
			<cfif ListFind(DebugUserRoles,idx) GT 0>
				<cfset blnSkipUserRoleForDebug = false>	
				<cfbreak>		
			</cfif>			
		</cfloop>
		<cfif blnSkipUserRoleForDebug>
			<cfset blnDoDebugFileWrite = false>
			<cfset strFileName="-- debug file write skipped (2).">			
		</cfif>
	</cfif>
	
	<!--- Allow selected capture of users regardless of IP based on existence of Session.UserID and the CSV list DebugUserIDs
	     If this is not a user whose output needs to be debugged we will set blnDoDebugFileWrite to false  (bilal 09-13-2008) --->
	<cfif (IsDefined("DebugUserIDs") AND IsDefined("Session.UserID") AND ListFind(DebugUserIDs,Session.UserID) IS 0)>
		<cfset blnDoDebugFileWrite = false>
		<cfset strFileName="-- debug file write skipped (3).">
	</cfif>

	<cfif blnDoDebugFileWrite>
		<cfset strFileName =  DateFormat(Now(),"yyyymmdd") & TimeFormat(Now(),"HHmmss")>
		<cfif IsDefined("CGI.CF_TEMPLATE_PATH")>
			<cfset strFileName = strFileName & "_" & ListLast(CGI.CF_TEMPLATE_PATH,"\")>
		</cfif>
		<cfif bFoundExceptions>
			<cfset strFileName = strFileName & "_ERR"> <!--- indicate error with different file --->
		<cfelseif IsDefined("DebugOnlyErrorToFile") AND DebugOnlyErrorToFile>
				<!--- if there is no error and we are directed to suppress the file do so (bsoylu 10-17-2009) --->
				<cfset blnDoDebugFileWrite = false>
				<cfset strFileName="-- debug file write skipped.">					
		</cfif>	
		<cfset strFileName = strFileName & ".htm"> <!--- extension --->
		<cfif IsDefined("Session.UserID")>
			<!--- session exists (bilal 09-09-2008) --->
			<cfset strDir = GetTempDirectory() & "U" & Session.UserID & "\"> 
			<cfif NOT DirectoryExists(strDir)>
				<cfdirectory action="CREATE" directory="#strDir#"> 
			</cfif>
			<cfset strFileName = strDir & Session.UserID & "_" & strFileName>
		<cfelse>
			<!--- no user specific directory, we will use U00 subdirectory (bilal 09-09-2008) --->
			<cfset strDir = GetTempDirectory() & "U00\"> 
			<cfif NOT DirectoryExists(strDir)>
				<cfdirectory action="CREATE" directory="#strDir#"> 
			</cfif>
			<cfset strFileName = strDir & "00_" & strFileName>
		</cfif>

		<cfif blnDoDebugFileWrite>
			<cffile action="WRITE" file="#strFileName#" output="#strDebugHTML#" addnewline="No" fixnewline="No">
			
			<cfif IsDefined("DebugErrorToEmail") AND DebugErrorToEmail CONTAINS "@">
				<!--- attempt to email this error --->
				<cftry>
					<cfmail to="#DebugErrorToEmail#" from="CFToFileDebugCapture@nowhere.com" subject="An Error occured during processing" mimeattach="#strFileName#">
					CFToFile Debug Capture detected an error during processing on this server.
					Please review attachment for details.
					</cfmail> 
					<cfcatch><!-- could not send debug email --></cfcatch>
				</cftry>			
			</cfif>
		</cfif>
	</cfif>		

	<cfif DebugSilent IS False>
		<br><!-- no debug file -->
		<cfif blnDoDebugFileWrite>
			<font size="-1" class="cfdebug"><i><cfoutput>Debug Rendering Time: #duration# ms // Debug Saved to #strFileName#</cfoutput></i></font><br />
		</cfif>
	</cfif>
</cfif>

<cffunction name="sortedScope" output="false">
    <cfargument name="scope">
    <cfset retVal="">
    <cfset keys = structKeyArray(scope)>
    <cfset arraySort(keys,"text")>
    <cfloop index="x" from=1 to="#arrayLen(keys)#">
    	<cfset keyName = keys[x]>
        <cfset retVal = retVal & keyName & "=">
           <cftry>
    		    <cfset keyValue = CFDebugSerializable(scope[keyname])>
    		<cfcatch>
    			<cfset keyValue = "undefined">
           	</cfcatch>
      	    </cftry>
        <cfset retVal = retVal & keyValue & Chr(13) & Chr(10)>
    </cfloop>
    <cfreturn retVal>
</cffunction>
