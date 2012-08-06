function LoadSectionConfigMap( $configurationFilePath )
{
    $result = @{}
    $config = [xml](get-content $configurationFilePath)
    
    $configDir = Split-Path $configurationFilePath -parent
    
    foreach ($addNode in $config.configuration.appsettings.add) {
     if ($addNode.Value.Contains(‘,’)) {
      # Array case
      $value = $addNode.Value.Split(‘,’)
      for ($i = 0; $i -lt $value.length; $i++) { 
        $value[$i] = $value[$i].Trim() 
      }
     }
     else {
      # Scalar case
      $value = $addNode.Value
     }
     $key = $addNode.Key     
     $result[$key] = Join-Path $configDir $value     
    }
    return $result
}

function ReplaceWebConfigSections( $templatePath, $EnvironmentConfigurationFile, $outputPath )
{
    $map = LoadSectionConfigMap $EnvironmentConfigurationFile
    ReplaceXmlSections $templatePath $map  $outputPath
}

function ReplaceXmlSections( $xmlFilePath , $SectionReplacementMap , $xmlOutputPath )
{
    $xml = [xml](get-content $xmlFilePath)
    foreach( $item in $SectionReplacementMap.GetEnumerator() )
    {
        ReplaceXmlSection $xml $item.Key $item.Value
    }

    $xml.Save($xmlOutputPath)
}

function ReplaceXmlSection( $RootXmlElement, $SectionName, $SectionFilePath )
{    
    $sectionQuery = "//{0}" -F $SectionName 
    $currentSectionRoot = $RootXmlElement.SelectSingleNode( $sectionQuery )       
    $sectionXmlRoot = [xml](get-content $SectionFilePath)
    $newSectionRoot = $sectionXmlRoot.SelectSingleNode( $sectionQuery )
    $newSectionRoot = $RootXmlElement.ImportNode( $newSectionRoot , $true )
    $r = $currentSectionRoot.ParentNode.ReplaceChild( $newSectionRoot, $currentSectionRoot )
}