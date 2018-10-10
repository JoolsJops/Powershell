# set no of processors to average % out and SQL instance to run for
$proc = 10 #Read-host {-Prompt "No. Of Processors" }
$SQLInstance = "LDS-LIDTSQL01,2007"
$Computer = "LDS-LIDTSQL01"
[int]$id = get-process -Name "sqlservr" -computername $Computer | select -ExpandProperty id 

$count = 0
#run until records returned sometime 0 percent found
While($threads.count -eq 0)
{
$threads = gwmi Win32_PerfFormattedData_PerfProc_Thread -ComputerName $Computer | 
    ?{$_.Name -notmatch '_Total' -and $_.IDProcess -ieq $id -and $_.PercentProcessorTime -igt 0} | 
    sort PercentProcessorTime -desc | select-object Name,IDProcess, IDThread,{($_.PercentProcessorTime) / $proc}

$count =$count+1
write-host "Attempt :"  $count
}
$threads


#set sql statement
$sql = "SELECT 
                r.session_id, os_thread_id,sub.[Percent],st.text/*, qp.query_plan, r.status*/
        FROM 
                sys.dm_os_threads AS ot
                JOIN sys.dm_os_tasks AS t     ON t.worker_address = ot.worker_address
                JOIN sys.dm_exec_requests AS r      ON t.session_id = r.session_id
                CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
                CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
                INNER JOIN (
        "
        

foreach ($thr in $threads)
{
# build up threads to loop through

        $sql = -join ($SQL,"SELECT "+$thr.IDThread.ToString() +" as [Thread], " +$thr.'($_.PercentProcessorTime) / $proc' +" as [Percent] UNION ALL ")

}
#remove last union all
    $sql = $sql.Substring(0,($sql.Length -10))
#add where clause
    $sql =-join($sql,") as sub  ON sub.Thread = ot.os_thread_id    WHERE r.session_id <>@@spid ")
#run sql and display
    Invoke-Sqlcmd -Query $sql -ServerInstance $SQLInstance -Database "Master" | out-gridview

#print $sql



#clear out variable
remove-variable threads,id,sqlinstance,proc,sql,count
