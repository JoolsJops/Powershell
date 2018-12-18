$FilePath = ''
$SheetName = ''
$ColumnNumber = 1

##open the excel file
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible=$false
$WorkBook=$Excel.Workbooks.Open($FilePath)

if ($strSheetName -eq "") {$worksheet = $WorkBook.sheets.Item(1)}
else {$worksheet = $WorkBook.sheets.Item($SheetName)}

[hashtable]$Duplicates = @{}

##loop through each row, group into a hashtable
$intRowMax = ($worksheet.UsedRange.Rows).count
for($intRow = 2 ; $intRow -le $intRowMax ; $intRow++)
    {
        $Value  = $worksheet.cells.item($intRow,$ColumnNumber).value2
        $Duplicates[$Value] = $Duplicates[$Value] + 1
    }  

$WorkBook.close()
$Excel.quit()
