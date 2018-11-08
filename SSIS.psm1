<# 
		.SYNOPSIS 
		.
		.DESCRIPTION

		.PARAMETER 

		.EXAMPLE

		.LINK

		.NOTES
		Version History  
		v1.0 - Dale Stewart - 20160623 00:00
#>
function Invoke-Assemblies
{
	param
	(
		[Parameter(position=1, Mandatory=$false)] [string]$SQLVersion
		#, [Parameter(position=3, Mandatory=$true)] [Microsoft.SqlServer.Dts.Runtime.Project]$Project 
	)

	#check the SSIS service is started!



	#Add-Type -AssemblyName 'Microsoft.SqlServer.TransactSql.ScriptDom, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'; 

	#Microsoft.SqlServer.Dts.Runtime.Wrapper.ConnectionManagerFileClass

	Add-Type -AssemblyName 'Microsoft.SqlServer.ManagedDTS, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTSRuntimeWrap, Version=9.0.242.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTSRuntimeWrap, Version=10.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTSRuntimeWrap, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTSRuntimeWrap, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' 
    Add-Type -Path "C:\Windows\Microsoft.NET\assembly\GAC_64\Microsoft.SqlServer.DTSRuntimeWrap\v4.0_12.0.0.0__89845dcd8080cc91\Microsoft.SQLServer.DTSRuntimeWrap.dll"
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTSRuntime, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'
	Add-Type -AssemblyName 'Microsoft.SqlServer.DTSPipelineWrap, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91'  
	#Add-Type -AssemblyName 'Microsoft.SqlServer.DTS, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91' 
	#Microsoft.SQLServer.PipelineHost 

}

<# 
		.SYNOPSIS 
		.
		.DESCRIPTION

		.PARAMETER 

		.EXAMPLE

		.LINK

		.NOTES
		Version History  
		v1.0 - Dale Stewart - 20160623 00:00
#>
function New-SSISApplication
{
	# param
	#(
	#[Parameter(position=1, Mandatory=$false)] [string]$SQLServer = ''
	#, [Parameter(position=2, Mandatory=$false)] [string]$Database = ''
	#, [Parameter(position=3, Mandatory=$true)] $File 
	# )
	Invoke-Assemblies
	$SSISApplication = New-Object Microsoft.SqlServer.Dts.Runtime.Application
	$SSISApplication 
}


<# 
		.SYNOPSIS 
		.
		.DESCRIPTION

		.PARAMETER 

		.EXAMPLE

		.LINK

		.NOTES
		Version History  
		v1.0 - Dale Stewart - 20170720 00:00
#>
function Redo-ScriptComponentCompile
{
	param
	(
		[Parameter(position=1, Mandatory=$true)] [string]$pkgLocation
        , [Parameter(position=2, Mandatory=$true)] [string]$NewSaveLocation
	)

       
	$app = New-SSISApplication
    $pkg = $app.LoadPackage($pkgLocation, $null)

	$Executables = $pkg.Executables
	$DataFlowTask = @()

	foreach ($Executable in $Executables)
	{
        foreach ($comp in $Executable.InnerObject.ComponentMetaDataCollection)
        {
            if ($comp.Name -eq "PK Hash") 
            {
            $compWrap = [System.Runtime.InteropServices.Marshal]::CreateWrapperOfType($comp.Instantiate() `
				, [Microsoft.SqlServer.Dts.Pipeline.Wrapper.CManagedComponentWrapperClass])

                #[Microsoft.SqlServer.Dts.Pipeline.Wrapper.CManagedComponentWrapper]$compWrap = $comp.Instantiate();
                [ScriptComponentHost] $scriptComp = [ScriptComponentHost]([IDTSManagedComponent100]$compWrap).InnerObject; 
                $scriptComp.LoadScriptFromComponent()

                if ($scriptComp.CurrentScriptingEngine.VstaHelper -eq $null) 
                { 
                    throw "Vsta 3.0 is not installed properly";
                } 
                $scriptComp.SaveScriptProject();
                $scriptComp.CurrentScriptingEngine.DisposeVstaHelper(); 
            }
        }
	}

}
