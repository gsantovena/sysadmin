$ScriptDirectory = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDirectory "..\common\loadConfig.ps1")

function GenerateNHibernateConfigurationFile( $TemplateFilePath, $ConfigurationFile, $OutputFile )
{
    LoadConfig "nhibernate-" $ConfigurationFile      
    $file_lines = gc $TemplateFilePath            
    $line_number = 0;
    $connection_line_number = 0
    $old_connection = ""
    $prefix_space = ""
    
    foreach ( $file_line in $file_lines )
    {
        $line_number++
        $result = $file_line -match "(\s+)<property name=`"connection.connection_string`">([^>]*)</property>"
        
        if( $result )
        {
            Write-Verbose ("Connection Line Found {0}" -F  $file_line)
            $connection_line_number = $line_number
            $old_connection = $matches[2] 
            $prefix_space = $matches[1]    
            break 
        }
    }                             
    
    $newConn = GenerateNHibernateConnectionString $old_connection
    $final_connection_line = "{0}<property name=`"connection.connection_string`">{1}</property>" -F $prefix_space, $newConn
    $file_lines[$connection_line_number-1] =  $final_connection_line
            
    Write-Verbose ("Final Connection Line {0}" -F $final_connection_line)
    
    $file_text = $file_lines | Out-String        
    
    Write-Verbose $OutputFile.GetType().FullName
    Write-Verbose $OutputFile[0]
    
    $file_text | new-item $OutputFile -type file -force
}

function GenerateNHibernateConnectionString( $connectionString ) 
{

    $nhHost = $appSettings["nhibernate-host"]
    $nhDatabase = $appSettings["nhibernate-database"]
    $nhUser = $appSettings["nhibernate-user"]
    $nhPassword = $appSettings["nhibernate-password"]

    $r = $connectionString -match "(Data Source=([^;]+);)"            
    $current = $matches[1] 
    $new = "Data Source={0};" -F $nhHost         
    $result = $connectionString -replace $current, $new
    
    $r = $connectionString -match "(Initial Catalog=([^;]+);)"            
    $current = $matches[1] 
    $new = "Initial Catalog={0};" -F $nhDatabase         
    $result = $result -replace $current, $new
    
    $r = $connectionString -match "(User Id=([^;]+);)"            
    $current = $matches[1] 
    $new = "User Id={0};" -F $nhUser         
    $result = $result -replace $current, $new
    
    $r = $connectionString -match "(Password=([^;]+);)"            
    $current = $matches[1] 
    $new = "Password={0};" -F $nhPassword
    $result = $result -replace $current, $new
    
    return $result
}