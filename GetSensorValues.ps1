<#
.SYNOPSIS
Sample function to retrieve values from sensors
.DESCRIPTION
Will use the combination of the the moisture sensor, particle and code to retrieve the values in a nice object form
Moisture sensor: https://www.tindie.com/products/miceuz/i2c-soil-moisture-sensor/
Code for particle: https://github.com/yerpj/SmartWatering
.NOTES  
File Name  : GetSensorValues.ps1  
Author     : Christoffer Järnåker  
License    : Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php 
Requires   : PowerShell V3   
#>



# Sample output
#  id                       name     moisture temperature luminance
#  --                       ----     -------- ----------- ---------
#  yyyyyyyyyyyyyyyyyyyyyyyy Jalapeno      436          29         9
#  zzzzzzzzzzzzzzzzzzzzzzzz Tomatoe       536          23        76


#
# Update these value with your own
            
$mytoken = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$mysensors = @( "yyyyyyyyyyyyyyyyyyyyyyyy-Jalapenjo",
                "zzzzzzzzzzzzzzzzzzzzzzzz-Tomatoe")

# End update

# Get the value from the particle service 
function GetVal($id, $type)
{ 
    $wr = iwr "https://api.particle.io/v1/devices/$id/CloudRequest?access_token=$mytoken" -Method POST -Body @{args=$type}
    return (ConvertFrom-Json $wr.Content).return_value
}

# Create and return an object with all the values
function GetValues($id,$name)
{
    return [PSCustomObject]@{
    id = $id
    name = $name
    moisture = GetVal $id "moisture"
    temperature = GetVal $id "temp"
    luminance = GetVal $id "lumi"
    } 
}

# Create an array of sensorvalues
[System.Collections.ArrayList]$sensorvalues = @{}

# Retrieve all sensorvalues
foreach($s in $mysensors)
    { 
        $v = ([string]$s).Split("-")
        $null = $sensorvalues.Add((GetValues $v[0] $v[1] ))
    }

# Output the result 
Write-Output $sensorvalues | ft *
